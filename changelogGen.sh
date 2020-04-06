#!/bin/bash
#==============================================================================
# title           : changelogGen.sh
# description     : An automatic changelog generator for git
# author		  : Jack Cooper (pog7776)
# date            : 03-04-2020
# version         : 1.1.1
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

# Init Args
AUTO_PUSH=false

# Loop through arguments and process them
for arg in "$@"
do
    case $arg in
        -p|--push)  # Will automatically commit and push changes to CHANGELOG.md
        AUTO_PUSH=true
        ;;
    esac
done

# Create CHANGELOG.md if it does not exist or empty
if [ ! -f "$CHLG" ] || [ $(echo "$CHLG") == "" ]
    then
        # Create CHANGELOG.md
        touch ./CHANGELOG.md
        # Set last update to the BEGINNING OF TIME
        SINCE=1901-01-01
    else
        # Find last changelog update
        SINCE=$(grep -A 1 '\[Date\]' $CHLG | tail -1 | grep -v "\[Date\]" | sed -e 's/\s\+/T/g')
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


# Handle auto push
if [ $AUTO_PUSH == true ] && [ $(git diff --exit-code CHANGELOG.md) ]
    then
        git reset
        echo "Staging changes to CHANGELOG.md"
        git add CHANGELOG.md
        echo "Committing changelog updates."
        git commit -m "Update Changelog" -m "Updating changelog automatically."
        echo "Pushing changes to CHANGELOG.md"
        git push
    else
        echo "No changes to CHANGELOG.md to push."
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

# TODO Add ability to generate since last version change instead of last date updated
# Would have to store version number in changelog or grep through git history
# TODO Don't need to have the tags infront of the changed under headings... since there are headings