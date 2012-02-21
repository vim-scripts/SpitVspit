"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  Plugin written and maintained by Gael Induni
" This is SpitVspit plugin to split among many files even :sp *.cpp<cr> works!!
"  Last modified: Mon 05 Sep 2011 01:53:10 PM CET
"  Version 2.1.3
"
"  Inspired from http://vim.wikia.com/wiki/Opening_multiple_files_from_a_single_command-line
"  By salmanhalim
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" To be always up-to-date:
" GetLatestVimScripts: 2918 1 :AutoInstall: SpitVspit

if exists("g:loaded_SpitVspit") && g:loaded_SpitVspit
	finish
endif
let g:loaded_SpitVspit = 1
let g:SpitVspit_version = "2.1.3"

function! Spit(choice,direction,...)
	let l:sp = "split"
	let l:isbelow = &splitbelow
	let l:isright = &splitright
	let l:dirchange = ""
	let l:w = 0
	let l:memory = 0
	let l:old_ok = 0
	let l:keep_first = ""
	let l:stop_cond = 1
	let l:old_file = @%
	let i = a:0
	if a:choice == 0 && ( ( a:direction > 0 && l:isbelow ) || ( a:direction < 0 && !l:isbelow ) )
		let l:dirchange = "set invsplitbelow"
	elseif a:choice == 1
		let l:sp = "vsplit"
		if ( a:direction > 0 && !l:isright ) || ( a:direction < 0 && l:isright )
			let l:dirchange = "set invsplitright"
		endif
	elseif a:choice == -1
		let l:w = 1
		let l:sp = "vsplit"
		if ( a:direction > 0 && !l:isright ) || ( a:direction < 0 && l:isright )
			let l:dirchange = "set invsplitright"
		endif
	elseif a:choice == 2
		if l:old_file != ""
			"let l:sp = l:sp . " " . l:old_file
			let l:old_ok = 1
			let l:sp = "99argadd"
		else
			let l:sp = "args"
		endif
		let i = 1
	endif
	execute l:dirchange
	if a:0 == 0 || empty(a:1)
		if a:choice != 2
			execute l:sp
		endif
	else
		while l:stop_cond
			execute "let file = expand( a:" . i ." )"
			if match( file, '*' ) > -1 || match( file, '\n' ) > -1
				let l:files = expand( file )
				if match( l:files, '*' ) != -1
					echoerr "Sorry, files " . l:files . " not found..."
					break
				endif
				while l:files != ""
					let l:thisfile = substitute( l:files, "\n.*$", "", "" )
					let l:files = substitute( l:files, l:thisfile, "", "" )
					let l:files = substitute( l:files, "^\n", "", "" )
					if l:keep_first == ""
						let l:keep_first = l:thisfile
					endif
					if a:choice < 2 && l:thisfile != l:old_file
						" Don't split *.* if current file
						execute l:sp . " " . l:thisfile
						if a:choice == -1 && l:w == 1
							let l:w = 0
							let l:sp = "split"
						endif
					elseif a:choice == 2
						let l:sp = l:sp . " " . l:thisfile
					endif
				endwhile
			else
				if l:keep_first == ""
					let l:keep_first = file
				endif
				if a:choice < 2
					execute l:sp . " " . file
					if a:choice == -1 && l:w == 1
						let l:w = 0
						let l:sp = "split"
						"let l:memory = &splitbelow
						"execute "set splitbelow"
					endif
				else
					let l:sp = l:sp . " " . file
				endif
			endif
			if a:choice < 2
				let i = i - 1
				let l:stop_cond = i > 0
			else
				let i = i + 1
				let l:stop_cond = i <= a:0
			endif
		endwhile
		if a:choice == 2
			execute l:sp
			if l:old_ok
				while @% != l:keep_first
					execute "next"
				endwhile
			endif
		endif
	endif
	execute l:dirchange
	"if a:choice == -1 && l:memory == 0
		"execute "set nosplitbelow"
	"endif
endfunction
" Creating new command names
com! -nargs=* -complete=file Spit       call Spit(0,0,<f-args>)
com! -nargs=* -complete=file Sp         call Spit(0,0,<f-args>)
com! -nargs=* -complete=file SpitUp     call Spit(0,1,<f-args>)
com! -nargs=* -complete=file Spu        call Spit(0,1,<f-args>)
com! -nargs=* -complete=file SpitDown   call Spit(0,-1,<f-args>)
com! -nargs=* -complete=file Spd        call Spit(0,-1<f-args>)
com! -nargs=* -complete=file Vspit      call Spit(1,0,<f-args>)
com! -nargs=* -complete=file Vsp        call Spit(1,0,<f-args>)
com! -nargs=* -complete=file VspitRight call Spit(1,1,<f-args>)
com! -nargs=* -complete=file Vspr       call Spit(1,1,<f-args>)
com! -nargs=* -complete=file VspitLeft  call Spit(1,-1,<f-args>)
com! -nargs=* -complete=file Vspl       call Spit(1,-1,<f-args>)
com! -nargs=* -complete=file Wspit      call Spit(-1,0,<f-args>)
com! -nargs=* -complete=file Wsp        call Spit(-1,0,<f-args>)
com! -nargs=* -complete=file WspitRight call Spit(-1,1,<f-args>)
com! -nargs=* -complete=file Wspr       call Spit(-1,1,<f-args>)
com! -nargs=* -complete=file WspitLeft  call Spit(-1,-1,<f-args>)
com! -nargs=* -complete=file Wspl       call Spit(-1,-1,<f-args>)
com! -nargs=* -complete=file E          call Spit(2,0,<f-args>)
" Redo command mapping
cab sp   Spit
cab spu  SpitUp
cab spd  SpitDown
cab vsp  Vspit
cab vspr VspitRight
cab vspl VspitLeft
cab wsp  Wspit
cab wspr WspitRight
cab wspl WspitLeft
"cab e    E
" Is the last one a good idea???

