local React = require("@Packages/React")

local e = React.createElement

export type Props = React.ElementProps<ScreenGui>

local function ScreenGui(props: Props)
	local screenGuiProps = {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
	}
	
	-- Pass through additional props like IgnoreGuiInset
	for key, value in pairs(props) do
		if key ~= "children" then
			screenGuiProps[key] = value
		end
	end
	
	return e("ScreenGui", screenGuiProps, props.children)
end

return ScreenGui