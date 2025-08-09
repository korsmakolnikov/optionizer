-- Optionizer
--
local M = {}

--- Metatable to manage access to option values.
-- The custom __index logic will return an option's value if the key exists,
-- or its default return value if inactive. Otherwise it redirects to the table itself.
local options_mt = {
  __index = function(t, k)
    if t.options[k] ~= nil then
      local option = t.options[k]
      if option.is_active then
        return option.value
      end
      return option.default_return_value
    end
    return t[k]
  end
}

-- Local variable to hold the single instance of the manager.
local instance = nil

--- Private constructor for the options manager.
-- Creates and initializes a new manager instance.
local function new_manager()
  local self = {
    options = {},
    active_options = {},
  }
  setmetatable(self, options_mt)
  return self
end

--- Constructor for the options manager.
-- Creates and initializes a new manager instance.
-- @return A new instance of the options manager.
function M.setup()
  if instance == nil then
    instance = new_manager()
  end

  vim.api.nvim_create_user_command(
    "OptionizerActiveOptions",
    M.get_active_options,
    { nargs = 0 }
  )

  return instance
end

--- Helper to retrieve the current manager instance.
-- This is the preferred interface for accessing the singleton.
-- @return The single instance of the options manager.
function M.get_instance()
  return instance
end

function M.optionizer_active_options()
  local self = M.get_instance() or M.setup()
  return self:get_active_options()
end

--- Adds a new option to the manager with an optional default return value.
-- @param self The manager instance.
-- @param option_name The key (name) of the option.
-- @param value The value of the option.
-- @param default_return_value Optional: A value to return when the option is inactive.
function M.add_option(self, option_name, value, default_return_value)
  self.options[option_name] = {
    value = value,
    is_active = false,
    default_return_value = default_return_value
  }
end

--- Activates a specific option by its name.
-- @param self The manager instance.
-- @param option_name The name of the option to activate.
function M.activate_option(self, option_name)
  if self.options[option_name] then
    self.options[option_name].is_active = true
    self.active_options[option_name] = true
    print("Option '" .. option_name .. "' activated.")
  else
    error("Option '" .. option_name .. "' does not exist.")
  end
end

--- Deactivates a specific option by its name.
-- @param self The manager instance.
-- @param option_name The name of the option to deactivate.
function M.deactivate_option(self, option_name)
  if self.options[option_name] then
    self.options[option_name].is_active = false
    self.active_options[option_name] = nil
    print("Option '" .. option_name .. "' deactivated.")
  else
    error("Option '" .. option_name .. "' does not exist.")
  end
end

--- Returns a list (table) of the names of all active options.
-- @param self The manager instance.
-- @return A table with the keys of the active options.
function M.get_active_options(self)
  local active_list = {}
  for key, _ in pairs(self.active_options) do
    table.insert(active_list, key)
  end
  return active_list
end

--- Returns a list (table) of the names of all inactive options.
-- @param self The manager instance.
-- @return A table with the keys of the inactive options.
function M.get_inactive_options(self)
  local inactive_list = {}
  for key, _ in pairs(self.options) do
    if not self.active_options[key] then
      table.insert(inactive_list, key)
    end
  end
  return inactive_list
end

return M
