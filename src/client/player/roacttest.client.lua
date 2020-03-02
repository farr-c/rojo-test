wait(3)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Roact = shared.import("Roact")
local Otter = shared.import("otter")

local Clock = Roact.Component:extend("Clock")

local mouse = game.Players.LocalPlayer:GetMouse()

local positionMotor = Otter.createGroupMotor({
    x = 0,
    y = 0,
})


function Clock:init()
    -- In init, we can use setState to set up our initial component state.
    self.clickCount, self.updateClickCount = Roact.createBinding(0)
    positionMotor:onStep(function(value)
        self.updateClickCount (value)
    end)
    
    self:setState({
        currentTime = 0
    })
end

-- This render function is almost completely unchanged from the first example.
function Clock:render()
    -- As a convention, we'll pull currentTime out of state right away.
    local currentTime = self.state.currentTime

    return Roact.createElement("ScreenGui", {}, {
        TimeLabel = Roact.createElement("TextLabel", {
            Size = UDim2.new(0.2, 0, 0.2, 0),
            Position = UDim2.new(0.4,0,0.4,0),
            Text = "Time Elapsed: " .. currentTime,
        })
    })
end

-- Set up our loop in didMount, so that it starts running when our
-- component is created.


local function updateMotor()
    positionMotor:setGoal({
        x = Otter.spring(mouse.X),
        y = Otter.spring(mouse.Y),
    })
end

function Clock:didMount()
    -- Set a value that we can change later to stop our loop
    self.running = true

    -- We don't want to block the main thread, so we spawn a new one!
    spawn(function()
        while self.running do
            -- Because we depend on the previous state, we use the function
            -- variant of setState. This will matter more when Roact gets
            -- asynchronous rendering!
            self:setState(function(state)
                updateMotor()
                return {
                    currentTime = state.currentTime + 1,
                    --isVisible = not state.isVisible
                }
            end)
            wait(1)
        end
    end)
end

-- Stop the loop in willUnmount, so that our loop terminates when the
-- component is destroyed.
function Clock:willUnmount()
    self.running = false
end




mouse.Move:Connect(updateMotor)

local PlayerGui = Players.LocalPlayer.PlayerGui




-- Create our UI, which now runs on its own!
local handle = Roact.mount(Roact.createElement(Clock), PlayerGui, "Clock UI")

-- Later, we can destroy our UI and disconnect everything correctly.

wait(30)
Roact.unmount(handle)

print("CHANGE HERE!")