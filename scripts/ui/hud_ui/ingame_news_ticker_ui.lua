IngameNewsTickerUI = class(IngameNewsTickerUI)
local REFRESH_TIMER_MESSAGE = 300
local REFRESH_TIMER_NO_MESSAGE = 120
local scenegraph_definition = {
	root = {
		scale = "fit",
		size = {
			1920,
			1080
		},
		position = {
			0,
			0,
			980
		}
	},
	news_ticker_text = {
		vertical_alignment = "bottom",
		parent = "root",
		horizontal_alignment = "right",
		size = {
			1920,
			20
		},
		position = {
			1920,
			0,
			2
		}
	},
	news_ticker_mask = {
		vertical_alignment = "bottom",
		parent = "root",
		horizontal_alignment = "right",
		size = {
			650,
			30
		},
		position = {
			0,
			0,
			3
		}
	}
}
local text_style = {
	word_wrap = true,
	font_size = 18,
	localize = false,
	use_shadow = true,
	horizontal_alignment = "left",
	vertical_alignment = "bottom",
	font_type = "hell_shark_masked",
	text_color = Colors.get_color_table_with_alpha("font_default", 255),
	offset = {
		0,
		0,
		2
	}
}
local widget_definitions = {
	news_ticker_text_widget = UIWidgets.create_simple_text("", "news_ticker_text", nil, nil, text_style),
	news_ticker_mask_widget = UIWidgets.create_simple_texture("mask_rect", "news_ticker_mask")
}

IngameNewsTickerUI.init = function (self, ingame_ui_context)
	self.ui_renderer = ingame_ui_context.ui_renderer
	self.input_manager = ingame_ui_context.input_manager
	self.platform = PLATFORM
	self.ui_animations = {}

	self:create_ui_elements()

	self.news_ticker_speed = 100
	self.news_ticker_manager = Managers.news_ticker

	self:refresh_message()
end

IngameNewsTickerUI.create_ui_elements = function (self)
	UIRenderer.clear_scenegraph_queue(self.ui_renderer)

	self.ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)
	self.news_ticker_text_widget = UIWidget.init(widget_definitions.news_ticker_text_widget)
	self.news_ticker_mask_widget = UIWidget.init(widget_definitions.news_ticker_mask_widget)
	local text_style = self.news_ticker_text_widget.style.text
	text_style.localize = false
	text_style.horizontal_alignment = "left"
end

IngameNewsTickerUI.destroy = function (self)
	GarbageLeakDetector.register_object(self, "ingame_news_ticker_ui")
end

IngameNewsTickerUI.refresh_message = function (self)
	self.refreshing_message = true
	self.news_ticker_started = nil

	self.news_ticker_manager:refresh_ingame_message()
end

IngameNewsTickerUI.update = function (self, dt, t)
	local news_ticker_manager = self.news_ticker_manager
	local news_ticker_started = self.news_ticker_started
	local refreshing_ingame_message = news_ticker_manager:refreshing_ingame_message()

	if not news_ticker_started and not refreshing_ingame_message then
		local news_ticker_text = news_ticker_manager:ingame_text()

		if news_ticker_text then
			self:setup_news_ticker(news_ticker_text)
		end

		if not self.message_refresh_delay then
			self.message_refresh_delay = (news_ticker_text and REFRESH_TIMER_MESSAGE) or REFRESH_TIMER_NO_MESSAGE
		end
	end

	local ui_scenegraph = self.ui_scenegraph
	local news_ticker_started = self.news_ticker_started

	if not self:handle_delay(dt) and news_ticker_started then
		local news_ticker_widget_position = ui_scenegraph.news_ticker_text.local_position

		if news_ticker_widget_position[1] + self.news_ticker_text_width <= 0 then
			news_ticker_widget_position[1] = 1920
			self.delay = 5
		end

		news_ticker_widget_position[1] = news_ticker_widget_position[1] - dt * self.news_ticker_speed

		self:draw(dt, t)
	end

	if not refreshing_ingame_message and not self:handle_message_refresh_delay(dt) then
		self:refresh_message()
	end
end

IngameNewsTickerUI.handle_delay = function (self, dt)
	local delay_time = self.delay

	if delay_time then
		delay_time = delay_time - dt
		self.delay = (0 < delay_time and delay_time) or nil

		return true
	end
end

IngameNewsTickerUI.handle_message_refresh_delay = function (self, dt)
	local delay_time = self.message_refresh_delay

	if delay_time then
		delay_time = delay_time - dt
		self.message_refresh_delay = (0 < delay_time and delay_time) or nil

		return true
	end
end

IngameNewsTickerUI.draw = function (self, dt, t)
	local ui_renderer = self.ui_renderer
	local ui_scenegraph = self.ui_scenegraph
	local input_manager = self.input_manager
	local input_service = input_manager:get_service("ingame_menu")
	local gamepad_active = input_manager:is_device_active("gamepad")

	UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt)
	UIRenderer.draw_widget(ui_renderer, self.news_ticker_mask_widget)
	UIRenderer.draw_widget(ui_renderer, self.news_ticker_text_widget)
	UIRenderer.end_pass(ui_renderer)
end

IngameNewsTickerUI.setup_news_ticker = function (self, text)
	local widget = self.news_ticker_text_widget
	local widget_content = widget.content
	local widget_style = widget.style
	widget_content.text = text
	local text_style = widget_style.text
	local font_type = text_style.font_type
	local font, scaled_font_size = UIFontByResolution(text_style)
	local fonts = DynamicFonts[font_type]
	local text_width, text_height, min = UIRenderer.text_size(self.ui_renderer, text, font[1], scaled_font_size)
	self.news_ticker_text_width = text_width
	self.news_ticker_started = true
end

return
