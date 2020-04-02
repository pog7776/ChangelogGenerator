#!/bin/bash
#==============================================================================
# title           : changelogGen.sh
# description     : An automatic changelog generator for git
# author		  : Jack Cooper (pog7776)
# date            : 03-04-2020
# version         : 1.1    
# usage		      : bash changelogGen.sh
# notes           : Install git to use this script. Add alias to .bashrc to use anywhere.
#==============================================================================
#
#       ----- Instructions -----
#
# In git commit messages use the following tags to categorize your work for the changelog
# Only lines of the commit with these tags will be included in the change log
# 
# [Added] : for new features.
# [Changed] : for changes in existing functionality.
# [Deprecated] : for once-stable features removed in upcoming releases.
# [Removed] : for deprecated features removed in this release.
# [Fixed] : for any bug fixes.
# [Security] : to invite users to upgrade in case of vulnerabilities.
#==============================================================================

CHLG=./CHANGELOG.md

declare -a tagNames=(Added Changed Deprecated Removed Fixed Security)
declare -A TAGS

# Create CHANGELOG.md if it does not exist or empty
if [ ! -f "$CHLG" ] || [ $(echo "$CHLG") == "" ]
    then
        # Create CHANGELOG.md
        touch ./CHANGELOG.md
        # Set last update to the BEGINNING OF TIME
        SINCE=1901-01-01
    else
        # Find last changelog update
        SINCE=$(grep -A1 '\[Date\]' $CHLG | grep -v "\[Date\]" | sed -e 's/\s\+/T/g')
        echo "Last update: " $(echo $SINCE | sed -e 's/,/ /g')
fi

# Find additions to changelog with tags
NEW=false
for t in ${tagNames[@]}; do
    # Search git log for tags
    TAGS["$t"]=$(git log --since="$SINCE" --grep="^\[$t\]" | grep "\[$t\]")
    
    #echo "${TAGS[$t]}"

    # Flag new content
    if [ "${TAGS[$t]}" != "" ]
        then
            NEW=true
    fi
done

# Handle if there are new additions to changelog
if [ $NEW == true ]
    then
        # Add space if the file is not empty
        if [ "$(cat $CHLG)" != "" ]
            then
                echo "" >> $CHLG
        fi

        # Add date of addition to changelog
        echo "[Date]" >> $CHLG
        echo `date +%F\ %T` >> $CHLG

        for t in ${!TAGS[@]}; do
            if [ "${TAGS[$t]}" != "" ]
                then
                    echo "* Adding additions to $t to CHANGELOG.md"

                    # Title the section
                    echo "========== [$t] ==========" >> $CHLG
                    
                    # Add additions to the changelog
                    echo "${TAGS[$t]}" | sed 's/\[$t\]/\n&/g' | sed 's/^/\*/'>> $CHLG
                else
                    echo "No additions to $t since last update"
            fi
        done
    else
        echo "No additions since last update"
fi


# ========== Old code, kept for reference if anything goes wrong ==========


# # Find [Added] tags
# ADDED=$(git log --since="$SINCE" --grep="^\[Added\]" | grep "\[Added\]")

# # Handle [Added] tags
# if [ "$ADDED" == "" ]
#     then
#         echo "No additions since last update"
#     else
#         echo "Adding additions to CHANGELOG.md"

#         # Add date of addition to changelog
#         echo "[Date]" >> $CHLG
#         date +%F >> $CHLG

#         # Add additions to the changelog
#         echo $ADDED | sed 's/\[Added\]/\n&/g' >> $CHLG
# fi