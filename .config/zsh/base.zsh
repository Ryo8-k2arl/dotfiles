#=================================================================================================#
##					 Base Configuration																																	 ##
#=================================================================================================#

# delete word by word with C-w when typing ls /usr/local/etc etc.
# default : ls /usr/local → ls /usr/ → ls /usr → ls /usr → ls /
# this setting : ls /usr/local → ls /usr/ → ls /usr/ → ls /
WORDCHARS='*?_-[]~&;!#$%^(){}<>|'


# Permissions when creating files
umask 022
