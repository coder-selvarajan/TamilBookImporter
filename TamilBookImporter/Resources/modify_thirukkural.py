import json

# Load kural-category.json
with open('kural-category.json', 'r', encoding='utf-8') as file:
    kural_category = json.load(file)

# Load thirukkural.json
with open('thirukkural.json', 'r', encoding='utf-8') as file:
    thirukkural = json.load(file)

# Extract chapters with their start and end numbers
chapters = []

for section in kural_category:
    if 'section' in section:
        for detail in section['section']['detail']:
            if 'chapterGroup' in detail:
                for chapter_detail in detail['chapterGroup']['detail']:
                    if 'chapters' in chapter_detail:
                        for chapter in chapter_detail['chapters']['detail']:
                            chapters.append({
                                'number': chapter['number'],
                                'name': chapter['name'],
                                'translation': chapter['translation'],
                                'start': chapter['start'],
                                'end': chapter['end']
                            })

# Add chapter information to each kural
for kural in thirukkural['kural']:
    kural_number = kural['Number']
    for chapter in chapters:
        if chapter['start'] <= kural_number <= chapter['end']:
            kural['section'] = chapter['name']
            break

# Save the modified thirukkural.json
with open('thirukkural_modified.json', 'w', encoding='utf-8') as file:
    json.dump(thirukkural, file, ensure_ascii=False, indent=4)

print("Modified JSON saved as thirukkural_modified.json")
