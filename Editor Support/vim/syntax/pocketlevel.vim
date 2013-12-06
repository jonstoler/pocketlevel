" Language: PocketLevel
" LICENSE:  The Happy License

if exists("b:current_syntax")
	finish
endif

if !exists('main_syntax')
	let main_syntax = 'pocketlevel'
endif

syn sync minlines=10
syn case ignore

syn match pocketlevelComment "#.*$"
syn match pocketlevelEmpty "\."

syn region pocketlevelLayout start="^{.*}$" skip="{objects}" end="^{.*}$" contains=pocketlevelEmpty

syn match pocketlevelHeader  "^{.*}$"

syntax include @toml syntax/toml.vim
syn region pocketlevelObjects start="^{objects}$" end="^{.*}$" contains=@toml, pocketlevelHeader

hi def link pocketlevelComment Comment
hi def link pocketlevelHeader  Title
hi def link pocketlevelEmpty   Comment

let b:current_syntax = 'pocketlevel'
