--[[
	UILib - Standalone Roblox UI Library
	Load externally via loadstring(game:HttpGet("URL"))()
	No external dependencies. Mobile-input supported.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UILib = {}
UILib.__index = UILib

-- ===== THEME =====
local Theme = {
	Background = Color3.fromRGB(30, 30, 35),
	Secondary = Color3.fromRGB(40, 40, 46),
	Accent = Color3.fromRGB(90, 120, 240),
	Text = Color3.fromRGB(235, 235, 240),
	SubText = Color3.fromRGB(160, 160, 170),
	Stroke = Color3.fromRGB(55, 55, 62),
}

-- ===== UTILITY =====
local function create(class, props, children)
	local inst = Instance.new(class)
	for prop, value in pairs(props or {}) do
		inst[prop] = value
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	return inst
end

local function tween(inst, props, duration, style)
	local t = TweenService:Create(
		inst,
		TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad),
		props
	)
	t:Play()
	return t
end

-- Makes any frame draggable using either mouse or touch input
local function makeDraggable(topBar, target)
	local dragging = false
	local dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		target.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topBar.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

-- ===== NOTIFICATIONS =====
local NotifHolder
local function ensureNotifHolder(screenGui)
	if NotifHolder then return NotifHolder end
	NotifHolder = create("Frame", {
		Name = "Notifications",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 280, 1, -20),
		Position = UDim2.new(1, -300, 0, 10),
		AnchorPoint = Vector2.new(0, 0),
		Parent = screenGui,
	}, {
		create("UIListLayout", {
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})
	return NotifHolder
end

function UILib:Notify(config)
	config = config or {}
	local title = config.Title or "Notification"
	local text = config.Text or ""
	local duration = config.Duration or 3

	local holder = ensureNotifHolder(self.ScreenGui)

	local card = create("Frame", {
		BackgroundColor3 = Theme.Secondary,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		create("UIStroke", { Color = Theme.Stroke, Thickness = 1 }),
		create("UIPadding", {
			PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12),
		}),
		create("UIListLayout", { Padding = UDim.new(0, 4) }),
		create("TextLabel", {
			Text = title,
			Font = Enum.Font.GothamBold,
			TextSize = 15,
			TextColor3 = Theme.Text,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		create("TextLabel", {
			Text = text,
			Font = Enum.Font.Gotham,
			TextSize = 13,
			TextColor3 = Theme.SubText,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})
	card.Parent = holder

	task.delay(duration, function()
		if card and card.Parent then
			tween(card, { BackgroundTransparency = 1 }, 0.3)
			task.wait(0.3)
			card:Destroy()
		end
	end)
end

-- ===== WINDOW =====
function UILib:CreateWindow(config)
	config = config or {}
	local windowTitle = config.Title or "UILib Window"

	local screenGui = create("ScreenGui", {
		Name = "UILib_" .. tostring(math.random(1, 999999)),
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = PlayerGui,
	})
	self.ScreenGui = screenGui

	local main = create("Frame", {
		Name = "Main",
		Size = UDim2.new(0, 480, 0, 320),
		Position = UDim2.new(0.5, -240, 0.5, -160),
		BackgroundColor3 = Theme.Background,
		Parent = screenGui,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 10) }),
		create("UIStroke", { Color = Theme.Stroke, Thickness = 1 }),
	})

	local topBar = create("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = Theme.Secondary,
		Parent = main,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 10) }),
		create("TextLabel", {
			Text = windowTitle,
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextColor3 = Theme.Text,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -40, 1, 0),
			Position = UDim2.new(0, 14, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})
	-- cover the bottom corners of the topbar so it looks square-joined with body
	create("Frame", {
		Size = UDim2.new(1, 0, 0, 10),
		Position = UDim2.new(0, 0, 1, -10),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = topBar,
	})

	local closeBtn = create("TextButton", {
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Theme.SubText,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 40, 1, 0),
		Position = UDim2.new(1, -40, 0, 0),
		Parent = topBar,
	})
	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	makeDraggable(topBar, main)

	local tabBar = create("Frame", {
		Name = "TabBar",
		Size = UDim2.new(0, 130, 1, -50),
		Position = UDim2.new(0, 10, 0, 50),
		BackgroundColor3 = Theme.Secondary,
		Parent = main,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		create("UIListLayout", { Padding = UDim.new(0, 4) }),
		create("UIPadding", {
			PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 6),
			PaddingRight = UDim.new(0, 6),
		}),
	})

	local pageHolder = create("Frame", {
		Name = "Pages",
		Size = UDim2.new(1, -160, 1, -50),
		Position = UDim2.new(0, 150, 0, 50),
		BackgroundTransparency = 1,
		Parent = main,
	})

	local window = setmetatable({
		ScreenGui = screenGui,
		Main = main,
		TabBar = tabBar,
		PageHolder = pageHolder,
		Tabs = {},
		ActivePage = nil,
	}, UILib)
	window.Notify = UILib.Notify -- reuse notification method with instance context

	return window
end

-- ===== TABS =====
function UILib:CreateTab(name)
	local button = create("TextButton", {
		Text = name,
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Theme.SubText,
		BackgroundColor3 = Theme.Background,
		Size = UDim2.new(1, 0, 0, 32),
		Parent = self.TabBar,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})

	local page = create("ScrollingFrame", {
		Name = name,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ScrollBarThickness = 4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.PageHolder,
	}, {
		create("UIListLayout", { Padding = UDim.new(0, 8) }),
	})

	local function selectTab()
		for _, tab in pairs(self.Tabs) do
			tab.Page.Visible = false
			tween(tab.Button, { BackgroundColor3 = Theme.Background, TextColor3 = Theme.SubText }, 0.15)
		end
		page.Visible = true
		tween(button, { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text }, 0.15)
	end

	button.MouseButton1Click:Connect(selectTab)

	local tabData = { Button = button, Page = page }
	table.insert(self.Tabs, tabData)

	if #self.Tabs == 1 then
		selectTab()
	end

	local tabObj = setmetatable({ Page = page }, UILib)
	return tabObj
end

-- ===== ELEMENTS =====
function UILib:CreateButton(config)
	config = config or {}
	local btn = create("TextButton", {
		Text = config.Text or "Button",
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Theme.Text,
		BackgroundColor3 = Theme.Secondary,
		Size = UDim2.new(1, 0, 0, 34),
		Parent = self.Page,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})

	btn.MouseButton1Click:Connect(function()
		if config.Callback then
			task.spawn(config.Callback)
		end
	end)

	return btn
end

function UILib:CreateToggle(config)
	config = config or {}
	local state = config.Default or false

	local holder = create("Frame", {
		BackgroundColor3 = Theme.Secondary,
		Size = UDim2.new(1, 0, 0, 34),
		Parent = self.Page,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		create("TextLabel", {
			Text = config.Text or "Toggle",
			Font = Enum.Font.Gotham,
			TextSize = 14,
			TextColor3 = Theme.Text,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -50, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	})

	local switch = create("Frame", {
		Size = UDim2.new(0, 36, 0, 20),
		Position = UDim2.new(1, -46, 0.5, -10),
		BackgroundColor3 = state and Theme.Accent or Theme.Stroke,
		Parent = holder,
	}, {
		create("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local knob = create("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
		BackgroundColor3 = Theme.Text,
		Parent = switch,
	}, {
		create("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local click = create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = holder,
	})

	click.MouseButton1Click:Connect(function()
		state = not state
		tween(switch, { BackgroundColor3 = state and Theme.Accent or Theme.Stroke }, 0.15)
		tween(knob, { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }, 0.15)
		if config.Callback then
			task.spawn(config.Callback, state)
		end
	end)

	return holder
end

function UILib:CreateSlider(config)
	config = config or {}
	local min = config.Min or 0
	local max = config.Max or 100
	local value = config.Default or min

	local holder = create("Frame", {
		BackgroundColor3 = Theme.Secondary,
		Size = UDim2.new(1, 0, 0, 46),
		Parent = self.Page,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		create("UIPadding", {
			PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 6),
		}),
	})

	local label = create("TextLabel", {
		Text = (config.Text or "Slider") .. ": " .. tostring(value),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.Text,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})

	local track = create("Frame", {
		Size = UDim2.new(1, 0, 0, 6),
		Position = UDim2.new(0, 0, 0, 28),
		BackgroundColor3 = Theme.Stroke,
		Parent = holder,
	}, {
		create("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local fillScale = (value - min) / (max - min)
	local fill = create("Frame", {
		Size = UDim2.new(fillScale, 0, 1, 0),
		BackgroundColor3 = Theme.Accent,
		Parent = track,
	}, {
		create("UICorner", { CornerRadius = UDim.new(1, 0) }),
	})

	local dragging = false

	local function setFromInputX(inputX)
		local rel = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		value = math.floor(min + (max - min) * rel)
		fill.Size = UDim2.new(rel, 0, 1, 0)
		label.Text = (config.Text or "Slider") .. ": " .. tostring(value)
		if config.Callback then
			task.spawn(config.Callback, value)
		end
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromInputX(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			setFromInputX(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return holder
end

function UILib:CreateDropdown(config)
	config = config or {}
	local options = config.Options or {}
	local selected = config.Default or options[1]
	local open = false

	local holder = create("Frame", {
		BackgroundColor3 = Theme.Secondary,
		Size = UDim2.new(1, 0, 0, 34),
		ClipsDescendants = true,
		Parent = self.Page,
	}, {
		create("UICorner", { CornerRadius = UDim.new(0, 6) }),
	})

	local label = create("TextLabel", {
		Text = (config.Text or "Select") .. ": " .. tostring(selected),
		Font = Enum.Font.Gotham,
		TextSize = 14,
		TextColor3 = Theme.Text,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -30, 0, 34),
		Position = UDim2.new(0, 10, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = holder,
	})

	local arrow = create("TextLabel", {
		Text = "▾",
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.SubText,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 24, 0, 34),
		Position = UDim2.new(1, -28, 0, 0),
		Parent = holder,
	})

	local optionList = create("Frame", {
		Position = UDim2.new(0, 0, 0, 34),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = holder,
	}, {
		create("UIListLayout", { Padding = UDim.new(0, 2) }),
	})

	local toggleClick = create("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 34),
		Parent = holder,
	})

	local function rebuildOptions()
		for _, c in ipairs(optionList:GetChildren()) do
			if not c:IsA("UIListLayout") then c:Destroy() end
		end
		for _, opt in ipairs(options) do
			local optBtn = create("TextButton", {
				Text = tostring(opt),
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextColor3 = Theme.SubText,
				BackgroundColor3 = Theme.Background,
				Size = UDim2.new(1, -10, 0, 28),
				Position = UDim2.new(0, 5, 0, 0),
				Parent = optionList,
			}, {
				create("UICorner", { CornerRadius = UDim.new(0, 4) }),
			})
			optBtn.MouseButton1Click:Connect(function()
				selected = opt
				label.Text = (config.Text or "Select") .. ": " .. tostring(selected)
				if config.Callback then
					task.spawn(config.Callback, selected)
				end
				open = false
				tween(holder, { Size = UDim2.new(1, 0, 0, 34) }, 0.15)
				tween(arrow, { Rotation = 0 }, 0.15)
			end)
		end
	end
	rebuildOptions()

	toggleClick.MouseButton1Click:Connect(function()
		open = not open
		local targetHeight = open and (34 + (#options * 30) + 6) or 34
		tween(holder, { Size = UDim2.new(1, 0, 0, targetHeight) }, 0.15)
		tween(arrow, { Rotation = open and 180 or 0 }, 0.15)
	end)

	return holder
end

return UILib
