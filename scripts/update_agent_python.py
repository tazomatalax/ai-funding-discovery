#!/usr/bin/env python3
import re
import sys
from datetime import datetime

def update_agent_file(target_file, new_lang, primary_lang, new_framework, new_db, current_branch):
    # Read existing file
    with open(target_file, 'r') as f:
        content = f.read()

    # Format framework for display (take first part before semicolon)
    if new_framework:
        display_framework = new_framework.split(';')[0].replace('Frontend: ', '').replace('Backend: ', '').strip()
    else:
        display_framework = ""

    # Check if new tech already exists
    tech_section = re.search(r'## Active Technologies\n(.*?)(?=\n## |\Z)', content, re.DOTALL)
    if tech_section:
        existing_tech = tech_section.group(1).strip()
        
        # Add new tech if not already present
        new_additions = []
        if primary_lang and current_branch not in existing_tech:
            if display_framework:
                new_additions.append(f"- {primary_lang} + {display_framework} ({current_branch})")
            else:
                new_additions.append(f"- {primary_lang} ({current_branch})")
        if new_db and new_db != "N/A" and new_db not in existing_tech:
            new_additions.append(f"- {new_db} ({current_branch})")
        
        if new_additions:
            if existing_tech:
                updated_tech = existing_tech + "\n" + "\n".join(new_additions)
            else:
                updated_tech = "\n".join(new_additions)
            content = re.sub(r'## Active Technologies\n.*?(?=\n## |\Z)', f"## Active Technologies\n{updated_tech}\n\n", content, flags=re.DOTALL)

    # Update project structure if needed
    project_type = new_framework  # Project type info is in framework for this case
    if "web" in str(project_type) and "frontend/" not in content:
        struct_section = re.search(r'## Project Structure\n```\n(.*?)\n```', content, re.DOTALL)
        if struct_section:
            current_struct = struct_section.group(1)
            if "backend/" not in current_struct:
                updated_struct = "backend/\nsrc/\ntests/\nfrontend/"
            else:
                updated_struct = current_struct + "\nfrontend/"
            content = re.sub(r'(## Project Structure\n```\n).*?(\n```)', 
                            f'\\1{updated_struct}\\2', content, flags=re.DOTALL)

    # Update commands based on detected technologies
    commands_section = re.search(r'## Commands\n(.*?)(?=\n## |\Z)', content, re.DOTALL)
    if commands_section:
        current_commands = commands_section.group(1).strip()
        
        # Generate new commands based on primary language
        new_commands = ""
        if "Python" in primary_lang:
            new_commands = "cd src && pytest && ruff check ."
        elif "Rust" in primary_lang:
            new_commands = "cargo test && cargo clippy"
        elif "JavaScript" in primary_lang or "TypeScript" in primary_lang:
            if "Next.js" in new_framework:
                new_commands = "npm run build && npm run test && npm run lint"
            else:
                new_commands = "npm test && npm run lint"
        elif primary_lang:
            new_commands = f"# Add commands for {primary_lang}"
        else:
            new_commands = "# Add commands for detected technologies"
        
        # Only update if we have a meaningful command and it's different
        if new_commands and not new_commands.startswith("#") and new_commands not in current_commands:
            content = re.sub(r'## Commands\n.*?(?=\n## |\Z)', f"## Commands\n{new_commands}\n\n", content, flags=re.DOTALL)
        elif new_commands.startswith("#") and "# Add commands" in current_commands:
            content = re.sub(r'## Commands\n.*?(?=\n## |\Z)', f"## Commands\n{new_commands}\n\n", content, flags=re.DOTALL)

    # Update recent changes (keep only last 3)
    changes_section = re.search(r'## Recent Changes\n(.*?)(?=\n## |\Z)', content, re.DOTALL)
    if changes_section:
        existing_changes = changes_section.group(1).strip()
        changes = [line for line in existing_changes.split('\n') if line.strip() and not line.strip().startswith(f"- {current_branch}:")]
        
        # Create new change entry
        if primary_lang and display_framework:
            new_change = f"- {current_branch}: Added {primary_lang} + {display_framework}"
        elif primary_lang:
            new_change = f"- {current_branch}: Added {primary_lang}"
        else:
            new_change = f"- {current_branch}: Updated project structure"
        
        changes.insert(0, new_change)
        # Keep only last 3
        changes = changes[:3]
        
        updated_changes = "\n".join(changes)
        content = re.sub(r'## Recent Changes\n.*?(?=\n## |\Z)', f"## Recent Changes\n{updated_changes}\n\n", content, flags=re.DOTALL)

    # Update date
    content = re.sub(r'Last updated: \d{4}-\d{2}-\d{2}', 
                    f'Last updated: {datetime.now().strftime("%Y-%m-%d")}', content)

    # Update code style section
    code_style_section = re.search(r'## Code Style\n(.*?)(?=\n## |\Z)', content, re.DOTALL)
    if code_style_section and primary_lang:
        new_code_style = f"{primary_lang}: Follow standard conventions"
        content = re.sub(r'## Code Style\n.*?(?=\n## |\Z)', f"## Code Style\n{new_code_style}\n\n", content, flags=re.DOTALL)

    # Write to temp file
    with open(sys.argv[1], 'w') as f:
        f.write(content)

if __name__ == "__main__":
    target_file = sys.argv[1]
    temp_file = sys.argv[2]
    new_lang = sys.argv[3]
    primary_lang = sys.argv[4]
    new_framework = sys.argv[5]
    new_db = sys.argv[6]
    current_branch = sys.argv[7]
    
    update_agent_file(target_file, new_lang, primary_lang, new_framework, new_db, current_branch)