#define _GNU_OURCE

#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#include "coverhunt.h"

#include "../stringop.h"
#include "../core.h"
#include "../core.h"


const char * cover_coverhunt_url(glyr_settings_t * sets)
{
    if(sets->cover.min_size <= 500 || sets->cover.min_size)
        return "http://www.coverhunt.com/index.php?query=%artist%+%album%&action=Find+my+CD+Covers";

    return NULL;
}

static bool check_size(const char * art_root, const char *hw, cb_object * capo)
{
    char * begin = strstr(art_root,hw);
    if(begin)
    {
        begin += strlen(hw);
        char * end = strchr(begin,' ');
        size_t len = end-begin;
        char * buf = malloc(len+1);
        if(buf)
        {
            strncpy(buf,begin,len);
            buf[len]   = '\0';

            int atoid = atoi(buf);
            free(buf);

            if((atoid >= capo->s->cover.min_size || capo->s->cover.min_size == -1) &&
                    (atoid <= capo->s->cover.max_size || capo->s->cover.max_size == -1)  )
                return true;
        }
    }

    return false;
}

// Take the first link we find.
// coverhunt sadly offers  no way to check if the
// image is really related to the query we're searching for
memCache_t * cover_coverhunt_parse(cb_object *capo)
{
    char * table_start, * table_end;
    if( (table_start = strstr(capo->cache->data,"<table><tr><td><a href=\"")) == NULL)
    {
        return NULL;
    }

    memCache_t * result_cache  = NULL;

    table_start += strlen("<table><tr><td><a href=\"");

    if( (table_end = strstr(table_start,"\"")) == NULL)
    {
        return NULL;
    }

    size_t go_url_len = table_end - table_start;

    char * go_url = malloc(go_url_len+1);
    if(go_url)
    {
        strncpy(go_url,table_start,go_url_len);
        go_url[go_url_len] = '\0';

        char * real_url = strdup_printf("http://www.coverhunt.com%s",go_url);
        free(go_url);

        if(real_url)
        {
            memCache_t * search_buf = download_single(real_url,capo->s);

            free(real_url);
            if(search_buf && search_buf->data)
            {
                char * art_root = strstr(search_buf->data,"<div class=\"artwork\">");
                if(art_root)
                {
                    if(check_size(art_root,"height=",capo) &&
                            check_size(art_root,"width=", capo)  )
                    {
                        char * img_src, *img_end;
                        if( (img_src = strstr(art_root,"<img src=\"")) != NULL)
                        {
                            img_src += strlen("<img src=\"");
                            if( (img_end = strstr(img_src,"\" ")) != NULL)
                            {
                                char * img_url = copy_value(img_src,img_end);
				if(img_url)
				{
					result_cache = DL_init();
					result_cache->data = img_url;
					result_cache->size = strlen(img_url);
				}
                            }
                        }
                    }
                }
                DL_free(search_buf);
            }
        }

    }
    return result_cache;
}
