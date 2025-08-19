-- Sprite UI Library v1.0
local Sprite = {}

-- Конфигурация
Sprite.Settings = {
    ToggleKey = Enum.KeyCode.Insert, -- Клавиша открытия/закрытия
    MainColor = Color3.fromRGB(30, 30, 30),
    AccentColor = Color3.fromRGB(0, 234, 129),
    TextColor = Color3.fromRGB(200, 200, 200),
    Font = Enum.Font.GothamSemibold
}

-- Создание главного окна
function Sprite:CreateWindow(name, size)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.Size = size or UDim2.new(0, 650, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
    mainFrame.BackgroundColor3 = self.Settings.MainColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Visible = false
    mainFrame.Parent = gui

    -- Курсор
    local cursor = Instance.new("Frame")
    cursor.Name = "Cursor"
    cursor.Size = UDim2.new(0, 10, 0, 10)
    cursor.BackgroundColor3 = self.Settings.AccentColor
    cursor.BorderSizePixel = 0
    cursor.ZIndex = 999
    cursor.Parent = gui

    -- Обработка клавиш
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == self.Settings.ToggleKey then
            mainFrame.Visible = not mainFrame.Visible
        end
    end)

    -- Движение курсора
    game:GetService("RunService").Stepped:Connect(function()
        local mouse = game.Players.LocalPlayer:GetMouse()
        cursor.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
        cursor.Visible = mainFrame.Visible
    end)

    self.GUI = gui
    self.MainFrame = mainFrame
    return self
end

-- Создание вкладки
function Sprite:CreateTab(name, icon)
    local tabButton = Instance.new("ImageButton")
    tabButton.Name = name .. "TabBtn"
    tabButton.Size = UDim2.new(0, 60, 0, 60)
    tabButton.BackgroundTransparency = 1
    tabButton.Image = icon or ""
    tabButton.Parent = self.MainFrame

    local tabFrame = Instance.new("Frame")
    tabFrame.Name = name .. "Tab"
    tabFrame.Size = UDim2.new(0.8, 0, 0.9, 0)
    tabFrame.Position = UDim2.new(0.2, 0, 0.05, 0)
    tabFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabFrame.Visible = false
    tabFrame.Parent = self.MainFrame

    tabButton.MouseButton1Click:Connect(function()
        for _, child in pairs(self.MainFrame:GetChildren()) do
            if child:IsA("Frame") and child.Name:find("Tab") then
                child.Visible = false
            end
        end
        tabFrame.Visible = true
    end)

    return tabFrame
end

-- Создание секции
function Sprite:CreateSection(tab, name)
    local section = Instance.new("Frame")
    section.Name = name .. "Section"
    section.Size = UDim2.new(0.45, 0, 0, 150)
    section.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    section.BorderSizePixel = 0
    section.Parent = tab

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = name
    title.TextColor3 = self.Settings.TextColor
    title.Font = self.Settings.Font
    title.TextSize = 14
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 20)
    title.Parent = section

    return section
end

-- Создание переключателя
function Sprite:CreateToggle(section, name, callback)
    local toggle = Instance.new("TextButton")
    toggle.Name = name .. "Toggle"
    toggle.Size = UDim2.new(1, -20, 0, 25)
    toggle.Position = UDim2.new(0, 10, 0, 30)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = section

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = name
    label.TextColor3 = self.Settings.TextColor
    label.Font = self.Settings.Font
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0.1, 0, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggle

    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(0.02, 0, 0.2, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggle

    local state = false

    toggle.MouseButton1Click:Connect(function()
        state = not state
        indicator.BackgroundColor3 = state and self.Settings.AccentColor or Color3.fromRGB(100, 100, 100)
        if callback then callback(state) end
    end)

    return {
        Set = function(self, value)
            state = value
            indicator.BackgroundColor3 = state and self.Settings.AccentColor or Color3.fromRGB(100, 100, 100)
        end,
        Get = function() return state end
    }
end

-- Создание слайдера
function Sprite:CreateSlider(section, name, min, max, callback)
    local slider = Instance.new("Frame")
    slider.Name = name .. "Slider"
    slider.Size = UDim2.new(1, -20, 0, 40)
    slider.BackgroundTransparency = 1
    slider.Parent = section

    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = self.Settings.TextColor
    label.Font = self.Settings.Font
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 15)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = slider

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 5)
    track.Position = UDim2.new(0, 0, 0, 20)
    track.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    track.BorderSizePixel = 0
    track.Parent = slider

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0.5, 0, 1, 0)
    fill.BackgroundColor3 = self.Settings.AccentColor
    fill.BorderSizePixel = 0
    fill.Parent = track

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Text = tostring(math.floor((max - min) * 0.5 + min))
    valueLabel.TextColor3 = self.Settings.TextColor
    valueLabel.Font = self.Settings.Font
    valueLabel.TextSize = 12
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(0, 50, 0, 15)
    valueLabel.Position = UDim2.new(1, -50, 0, 20)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = slider

    local dragging = false
    local function update(value)
        local percent = (value - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        valueLabel.Text = tostring(math.floor(value))
        if callback then callback(value) end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local mouse = game:GetService("Players").LocalPlayer:GetMouse()
            local percent = (mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            percent = math.clamp(percent, 0, 1)
            local value = min + (max - min) * percent
            update(value)
        end
    end)

    update((max - min) * 0.5 + min) -- Установка среднего значения

    return {
        Set = function(self, value)
            update(math.clamp(value, min, max))
        end,
        Get = function()
            return tonumber(valueLabel.Text)
        end
    }
end

return Sprite
