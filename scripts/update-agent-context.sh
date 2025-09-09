#!/usr/bin/env bash
# Incrementally update agent context files based on new feature plan
# Supports: CLAUDE.md, GEMINI.md, and .github/copilot-instructions.md
# O(1) operation - only reads current context file and new plan.md

set -e

REPO_ROOT=$(git rev-parse --show-toplevel)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
FEATURE_DIR="$REPO_ROOT/specs/$CURRENT_BRANCH"
NEW_PLAN="$FEATURE_DIR/plan.md"

# Determine which agent context files to update
CLAUDE_FILE="$REPO_ROOT/CLAUDE.md"
GEMINI_FILE="$REPO_ROOT/GEMINI.md"
COPILOT_FILE="$REPO_ROOT/.github/copilot-instructions.md"

# Allow override via argument
AGENT_TYPE="$1"

if [ ! -f "$NEW_PLAN" ]; then
    echo "ERROR: No plan.md found at $NEW_PLAN"
    exit 1
fi

echo "=== Updating agent context files for feature $CURRENT_BRANCH ==="

# Extract tech from new plan - handle actual format from template
NEW_LANG=$(grep "\*\*Language/Version\*\*: " "$NEW_PLAN" 2>/dev/null | head -1 | sed 's/.*\*\*Language\/Version\*\*: //' | sed 's/ *$//' | grep -v "NEEDS CLARIFICATION" || echo "")
NEW_FRAMEWORK=$(grep "\*\*Primary Dependencies\*\*: " "$NEW_PLAN" 2>/dev/null | head -1 | sed 's/.*\*\*Primary Dependencies\*\*: //' | sed 's/ *$//' | grep -v "NEEDS CLARIFICATION" || echo "")
NEW_TESTING=$(grep "\*\*Testing\*\*: " "$NEW_PLAN" 2>/dev/null | head -1 | sed 's/.*\*\*Testing\*\*: //' | sed 's/ *$//' | grep -v "NEEDS CLARIFICATION" || echo "")
NEW_DB=$(grep "\*\*Storage\*\*: " "$NEW_PLAN" 2>/dev/null | head -1 | sed 's/.*\*\*Storage\*\*: //' | sed 's/ *$//' | grep -v "N/A" | grep -v "NEEDS CLARIFICATION" || echo "")
NEW_PROJECT_TYPE=$(grep "\*\*Project Type\*\*: " "$NEW_PLAN" 2>/dev/null | head -1 | sed 's/.*\*\*Project Type\*\*: //' | sed 's/ *$//' || echo "")

# Extract primary language for commands generation
PRIMARY_LANG=$(echo "$NEW_LANG" | sed 's/(.*//' | sed 's/,.*//' | sed 's/ *$//')

# Debug output
echo "Extracted values:"
echo "  Language: '$NEW_LANG'"
echo "  Primary: '$PRIMARY_LANG'"
echo "  Framework: '$NEW_FRAMEWORK'"
echo "  Storage: '$NEW_DB'"
echo "  Project Type: '$NEW_PROJECT_TYPE'"

# Function to update a single agent context file
update_agent_file() {
    local target_file="$1"
    local agent_name="$2"
    
    echo "Updating $agent_name context file: $target_file"
    
    # Create temp file for new context
    local temp_file=$(mktemp)
    
    # If file doesn't exist, create from template
    if [ ! -f "$target_file" ]; then
        echo "Creating new $agent_name context file..."
        
        # Check if this is the SDD repo itself
        if [ -f "$REPO_ROOT/templates/agent-file-template.md" ]; then
            cp "$REPO_ROOT/templates/agent-file-template.md" "$temp_file"
        else
            echo "ERROR: Template not found at $REPO_ROOT/templates/agent-file-template.md"
            return 1
        fi
        
        # Replace placeholders with better formatting
        PROJECT_NAME=$(basename "$REPO_ROOT")
        CURRENT_DATE=$(date +%Y-%m-%d)
        
        # Format tech stack entry
        if [ -n "$NEW_LANG" ] && [ -n "$NEW_FRAMEWORK" ]; then
            TECH_ENTRY="- $PRIMARY_LANG + $(echo "$NEW_FRAMEWORK" | cut -d';' -f1 | sed 's/Frontend: //g' | sed 's/Backend: //g') ($CURRENT_BRANCH)"
        elif [ -n "$NEW_LANG" ]; then
            TECH_ENTRY="- $PRIMARY_LANG ($CURRENT_BRANCH)"
        else
            TECH_ENTRY="- Unknown stack ($CURRENT_BRANCH)"
        fi
        
        sed -i.bak "s/\[PROJECT NAME\]/$PROJECT_NAME/" "$temp_file"
        sed -i.bak "s/\[DATE\]/$CURRENT_DATE/" "$temp_file"
        sed -i.bak "s|\[EXTRACTED FROM ALL PLAN.MD FILES\]|$TECH_ENTRY|" "$temp_file"
        
        # Add project structure based on type
        if [[ "$NEW_PROJECT_TYPE" == *"web"* ]]; then
            sed -i.bak "s|\[ACTUAL STRUCTURE FROM PLANS\]|backend/\nfrontend/\ntests/|" "$temp_file"
        else
            sed -i.bak "s|\[ACTUAL STRUCTURE FROM PLANS\]|src/\ntests/|" "$temp_file"
        fi
        
        # Add commands based on detected tech
        COMMANDS=""
        if [[ "$PRIMARY_LANG" == *"Python"* ]]; then
            COMMANDS="cd src && pytest && ruff check ."
        elif [[ "$PRIMARY_LANG" == *"Rust"* ]]; then
            COMMANDS="cargo test && cargo clippy"
        elif [[ "$PRIMARY_LANG" == *"JavaScript"* ]] || [[ "$PRIMARY_LANG" == *"TypeScript"* ]]; then
            if [[ "$NEW_FRAMEWORK" == *"Next.js"* ]]; then
                COMMANDS="npm run build && npm run test && npm run lint"
            else
                COMMANDS="npm test && npm run lint"
            fi
        elif [ -n "$PRIMARY_LANG" ]; then
            COMMANDS="# Add commands for $PRIMARY_LANG"
        else
            COMMANDS="# Add commands for detected technologies"
        fi
        # Use a more robust replacement method for commands that may contain special chars
        python3 -c "
import sys
with open('$temp_file', 'r') as f: content = f.read()
content = content.replace('[ONLY COMMANDS FOR ACTIVE TECHNOLOGIES]', '''$COMMANDS''')
with open('$temp_file', 'w') as f: f.write(content)
"
        
        # Add code style
        if [ -n "$PRIMARY_LANG" ]; then
            CODE_STYLE="$PRIMARY_LANG: Follow standard conventions"
        else
            CODE_STYLE="Follow standard conventions"
        fi
        sed -i.bak "s|\[LANGUAGE-SPECIFIC, ONLY FOR LANGUAGES IN USE\]|$CODE_STYLE|" "$temp_file"
        
        # Add recent changes
        if [ -n "$NEW_LANG" ] && [ -n "$NEW_FRAMEWORK" ]; then
            RECENT_CHANGE="- $CURRENT_BRANCH: Added $PRIMARY_LANG + $(echo "$NEW_FRAMEWORK" | cut -d';' -f1 | sed 's/Frontend: //g' | sed 's/Backend: //g')"
        elif [ -n "$NEW_LANG" ]; then
            RECENT_CHANGE="- $CURRENT_BRANCH: Added $PRIMARY_LANG"
        else
            RECENT_CHANGE="- $CURRENT_BRANCH: Updated project structure"
        fi
        sed -i.bak "s|\[LAST 3 FEATURES AND WHAT THEY ADDED\]|$RECENT_CHANGE|" "$temp_file"
        
        rm "$temp_file.bak"
    else
        echo "Updating existing $agent_name context file..."
        
        # Extract manual additions
        local manual_start=$(grep -n "<!-- MANUAL ADDITIONS START -->" "$target_file" | cut -d: -f1)
        local manual_end=$(grep -n "<!-- MANUAL ADDITIONS END -->" "$target_file" | cut -d: -f1)
        
        if [ ! -z "$manual_start" ] && [ ! -z "$manual_end" ]; then
            sed -n "${manual_start},${manual_end}p" "$target_file" > /tmp/manual_additions.txt
        fi
        
        # Parse existing file and create updated version using external script
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        python3 "$SCRIPT_DIR/update_agent_python.py" "$target_file" "$temp_file" "$NEW_LANG" "$PRIMARY_LANG" "$NEW_FRAMEWORK" "$NEW_DB" "$CURRENT_BRANCH"

        # Restore manual additions if they exist
        if [ -f /tmp/manual_additions.txt ]; then
            # Remove old manual section from temp file
            sed -i.bak '/<!-- MANUAL ADDITIONS START -->/,/<!-- MANUAL ADDITIONS END -->/d' "$temp_file"
            # Append manual additions
            cat /tmp/manual_additions.txt >> "$temp_file"
            rm /tmp/manual_additions.txt "$temp_file.bak"
        fi
    fi
    
    # Move temp file to final location
    mv "$temp_file" "$target_file"
    echo "✅ $agent_name context file updated successfully"
}

# Update files based on argument or detect existing files
case "$AGENT_TYPE" in
    "claude")
        update_agent_file "$CLAUDE_FILE" "Claude Code"
        ;;
    "gemini") 
        update_agent_file "$GEMINI_FILE" "Gemini CLI"
        ;;
    "copilot")
        update_agent_file "$COPILOT_FILE" "GitHub Copilot"
        ;;
    "")
        # Update all existing files
        [ -f "$CLAUDE_FILE" ] && update_agent_file "$CLAUDE_FILE" "Claude Code"
        [ -f "$GEMINI_FILE" ] && update_agent_file "$GEMINI_FILE" "Gemini CLI" 
        [ -f "$COPILOT_FILE" ] && update_agent_file "$COPILOT_FILE" "GitHub Copilot"
        
        # If no files exist, create based on current directory or ask user
        if [ ! -f "$CLAUDE_FILE" ] && [ ! -f "$GEMINI_FILE" ] && [ ! -f "$COPILOT_FILE" ]; then
            echo "No agent context files found. Creating Claude Code context file by default."
            update_agent_file "$CLAUDE_FILE" "Claude Code"
        fi
        ;;
    *)
        echo "ERROR: Unknown agent type '$AGENT_TYPE'. Use: claude, gemini, copilot, or leave empty for all."
        exit 1
        ;;
esac
echo ""
echo "Summary of changes:"
if [ ! -z "$NEW_LANG" ]; then
    echo "- Added language: $NEW_LANG"
fi
if [ ! -z "$NEW_FRAMEWORK" ]; then
    echo "- Added framework: $NEW_FRAMEWORK"
fi
if [ ! -z "$NEW_DB" ] && [ "$NEW_DB" != "N/A" ]; then
    echo "- Added database: $NEW_DB"
fi

echo ""
echo "Usage: $0 [claude|gemini|copilot]"
echo "  - No argument: Update all existing agent context files"
echo "  - claude: Update only CLAUDE.md"
echo "  - gemini: Update only GEMINI.md" 
echo "  - copilot: Update only .github/copilot-instructions.md"