#!/usr/bin/env bash
hexo g 
hexo d 
git add . 
git commit -m 'update' 
git push