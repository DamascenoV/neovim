local status, flutter = pcall(require, 'flutter-tools')
if not status then return end

flutter.setup {}
