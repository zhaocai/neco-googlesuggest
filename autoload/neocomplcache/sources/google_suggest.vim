let s:source = {
            \ 'name': 'google_suggest',
            \ 'kind': 'plugin',
            \ }

call zl#rc#set_default({
            \ 'g:neco_source_google_suggest_disable'              : 1,
            \ 'g:neco_source_google_suggest_language'             : 'en',
            \})



function! s:source.initialize()
    call neocomplcache#set_completion_length('google_suggest', 3)

    " Set rank.
    call neocomplcache#set_dictionary_helper(g:neocomplcache_source_rank,
          \ 'google_suggest', 3)

    let g:neocomplcache_source_disable['google_suggest'] = g:neco_source_google_suggest_disable

    command! NeoComplCacheToggleGoogleSuggest call s:toggle()
endfunction

function! s:source.finalize()
    delcommand NeoComplCacheToggleGoogleSuggest

    let s:source = {}
endfunction

function! s:source.get_keyword_list(cur_keyword_str)
    if g:neco_source_google_suggest_disable
        return []
    endif
    return map(s:get_google_suggest(a:cur_keyword_str, g:neco_source_google_suggest_language),
                \ "{'word': v:val, 'menu': 'google_suggest'}")
endfunction

function! neocomplcache#sources#google_suggest#define()
    return s:source
endfunction

function! s:toggle()
    let g:neco_source_google_suggest_disable = !g:neco_source_google_suggest_disable

    let g:neocomplcache_source_disable['google_suggest'] = g:neco_source_google_suggest_disable

    let status = g:neco_source_google_suggest_disable ? 'off' : 'on'
    echo "Google Suggest: " . status
endfunction

function! s:get_google_suggest(cur_keyword_str, language)
    let keyword_list = []
    let res = webapi#http#get(
                \ 'http://suggestqueries.google.com/complete/search',
                \ {
                    \ "client" : "youtube"         ,
                    \ "q"      : a:cur_keyword_str ,
                    \ "hjson"  : "t"               ,
                    \ "hl"     : a:language        ,
                    \ "ie"     : "UTF8"            ,
                    \ "oe"     : "UTF8"
                \ }
            \ )
    let arr = webapi#json#decode(res.content)
    for m in arr[1]
        call add(keyword_list, m[0])
    endfor
    return keyword_list
endfunction

