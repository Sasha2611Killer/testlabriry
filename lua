-- Sprite UI Library v1.0 - Fixed Version
local Sprite = {}

-- Конфигурация
Sprite.Settings = {
    ToggleKey = Enum.KeyCode.Insert,
    MainColor = Color3.fromRGB(30, 30, 30),
    AccentColor = Color3.fromRGB(0, 234, 129),
    TextColor = Color3.fromRGB(200, 200, 200),
    Font = Enum.Font.GothamSemibold
}

-- Создание главного окна
function Sprite.CreateWindow(name, size)
    local self = setmetatable({}, {__index = Sprite})
    
    local gui = Instance.new("ScreenGui")
    gui.Name = name or "SpriteUI"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "Main"
    mainFrame.Size = size or UDim2.new(0, 650, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -325, 0.5, -250)
    mainFrame.BackgroundColor3 = Sprite.Settings.MainColor
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = false
    mainFrame.Parent = gui

    -- Верхняя панель
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 25)
    topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Text = name or "Sprite UI"
    title.TextColor3 = Sprite.Settings.TextColor
    title.Font = Sprite.Settings.Font
    title.TextSize = 14
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 1, 0)
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Parent = topBar

    -- Панель вкладок слева
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(0, 80, 1, -25)
    tabContainer.Position = UDim2.new(0, 0, 0, 25)
    tabContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame

    -- Контейнер для контента
    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "Content"
    contentContainer.Size = UDim2.new(1, -80, 1, -25)
    contentContainer.Position = UDim2.new(0, 80, 0, 25)
    contentContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame

    -- Курсор
    local cursor = Instance.new("Frame")
    cursor.Name = "Cursor"
    cursor.Size = UDim2.new(0, 10, 0, 10)
    cursor.BackgroundColor3 = Sprite.Settings.AccentColor
    cursor.BorderSizePixel = 0
    cursor.ZIndex = 999
    cursor.Visible = false
    cursor.Parent = gui

    -- Обработка клавиш
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == Sprite.Settings.ToggleKey then
            mainFrame.Visible = not mainFrame.Visible
            cursor.Visible = mainFrame.Visible
            
            if mainFrame.Visible then
                game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.Default
            else
                game:GetService("UserInputService").MouseBehavior = Enum.MouseBehavior.LockCenter
            end
        end
    end)

    -- Движение курсора
    game:GetService("RunService").RenderStepped:Connect(function()
        local mouse = game.Players.LocalPlayer:GetMouse()
        cursor.Position = UDim2.new(0, mouse.X - 5, 0, mouse.Y - 5)
    end)

    self.GUI = gui
    self.MainFrame = mainFrame
    self.TabContainer = tabContainer
    self.ContentContainer = contentContainer
    self.Tabs = {}
    
    return self
end

-- Создание вкладки
function Sprite:CreateTab(name, iconId)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = name .. "TabBtn"
    tabButton.Size = UDim2.new(1, -10, 0, 60)
    tabButton.Position = UDim2.new(0, 5, 0, #self.Tabs * 65 + 10)
    tabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""
    tabButton.AutoButtonColor = false
    tabButton.Parent = self.TabContainer

    if iconId then
        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.new(0, 30, 0, 30)
        icon.Position = UDim2.new(0.5, -15, 0.2, 0)
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. tostring(iconId)
        icon.Parent = tabButton
    end

    local label = Instance.new("TextLabel")
    label.Text = name
    label.TextColor3 = Sprite.Settings.TextColor
    label.Font = Sprite.Settings.Font
    label.TextSize = 12
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0.7, 0)
    label.Parent = tabButton

    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = name .. "Tab"
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = 5
    tabFrame.Visible = false
    tabFrame.Parent = self.ContentContainer

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 10)
    uiListLayout.Parent = tabFrame

    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(self.Tabs) do
            tab.Frame.Visible = false
        end
        tabFrame.Visible = true
    end)

    local tabData = {
        Button = tabButton,
        Frame = tabFrame,
        Name = name
    }
    
    table.insert(self.Tabs, tabData)
    
    -- Автоматически показываем первую вкладку
    if #self.Tabs == 1 then
        tabFrame.Visible = true
    end
    
    return self
end

-- Создание секции
function Sprite:CreateSection(name)
    if #self.Tabs == 0 then
        warn("Сначала создайте вкладку!")
        return nil
    end
    
    local currentTab = self.Tabs[#self.Tabs].Frame
    
    local section = Instance.new("Frame")
    section.Name = name .. "Section"
    section.Size = UDim2.new(1, -20, 0, 0)
    section.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    section.BorderSizePixel = 0
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.Position = UDim2.new(0, 10, 0, (#currentTab:GetChildren() - 1) * 160 + 10)
    section.Parent = currentTab

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = name
    title.TextColor3 = Sprite.Settings.TextColor
    title.Font = Sprite.Settings.Font
    title.TextSize = 16
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, 30)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = section

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.BackgroundTransparency = 1
    content.AutomaticSize = Enum.AutomaticSize.Y
    content.Position = UDim2.new(0, 0, 0, 30)
    content.Parent = section

    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.Parent = content

    return content
end

-- Создание переключателя
function Sprite:CreateToggle(section, name, callback)
    local toggle = Instance.new("TextButton")
    toggle.Name = name .. "Toggle"
    toggle.Size = UDim2.new(1, 0, 0, 25)
    toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    toggle.Text = ""
    toggle.AutoButtonColor = false
    toggle.Parent = section

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = name
    label.TextColor3 = Sprite.Settings.TextColor
    label.Font = Sprite.Settings.Font
    label.TextSize = 14
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
        indicator.BackgroundColor3 = state and Sprite.Settings.AccentColor or Color3.fromRGB(100, 100, 100)
        if callback then callback(state) end
    end)

    return {
        Set = function(value)
            state = value
            indicator.BackgroundColor3 = state and Sprite.Settings.AccentColor or Color3.fromRGB(100, 100, 100)
            if callback then callback(state) end
        end,
        Get = function() return state end
    }
end

return Sprite
