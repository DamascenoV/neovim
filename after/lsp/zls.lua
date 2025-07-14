return {
  cmd = { os.getenv("HOME") .. "/zig/zls/zig-out/bin/zls" },
  filetypes = { "zig", "zir" },
  root_markers = { "zls.json", "build.zig", ".git" }
}
