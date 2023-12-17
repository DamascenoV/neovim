local status, ocaml = pcall(require, 'ocaml')
if not status then return end

ocaml.update()
ocaml.setup()
