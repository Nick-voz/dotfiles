function fish_user_key_bindings
    # ctrl+v = \x16 literal (not clipboard paste)
    # ctrl+c = interrupt (not copy — Win+C handled by xremap/kitty)
    bind ctrl-v self-insert
    bind ctrl-c cancel-commandline
end
