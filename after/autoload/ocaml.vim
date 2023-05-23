if executable('opam')
  let g:opamshare=substitute(system('opam var share'),'\n$','','''')
  execute "set rtp+=" . g:opamshare."/merlin/vim"
  let g:syntastic_ocaml_checkers = ['merlin']
endif
