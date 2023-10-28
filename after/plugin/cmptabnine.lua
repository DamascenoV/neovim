local status, tabnine = pcall(require, 'cmp-tabnine')
if not status then return end

tabnine:setup({
	max_lines = 1000,
	max_num_results = 20,
	sort = true,
	run_on_every_keystroke = true,
	snippet_placeholder = '..',
	ignored_file_types = {},
	show_prediction_strength = false
})
