import re


lines = []

with open("map_orig.tscn", "r") as f:
    lines = f.readlines()


split_re = re.compile(r'')

found_split = False

pre_lines = []

post_lines = []


for line in lines:

    if line.strip() == '[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_ji6ut"]':

        found_split = True
    

    if found_split:
        post_lines.append(line)

    else:
        pre_lines.append(line)

tiles_with_physics = []

for line in post_lines:
    if line.strip() == '[sub_resource type="TileSet" id="TileSet_uqhut"]':
        break
    tiles_with_physics.append(line)
    
physics_defs = []
physics_def_re = re.compile(r"([^:]+):([^/]+)/([^/]+)/physics_layer_0/polygon_0/points = PackedVector2Array\(([^\)]+)\)")
for line in tiles_with_physics:
    matches = physics_def_re.search(line)
    if matches:
        physics_defs.append(matches)

sub_resources = []
for matches in physics_defs:
    original = matches.group(0)
    pos_x = matches.group(1)
    pos_y = matches.group(2)
    pos_sub = matches.group(3)
    values = matches.group(4)
    
    uid = f"gen_{pos_x}_{pos_y}_{pos_sub}"
    
    sr = f'\n[sub_resource type="OccluderPolygon2D" id="OccluderPolygon2D_{uid}"]\npolygon = PackedVector2Array({values})\n'
    sd = f'{pos_x}:{pos_y}/{pos_sub}/occlusion_layer_0/polygon = SubResource("OccluderPolygon2D_{uid}")\n'

    sub_resources.append((original, sr, sd))
    
    
output = []

output += pre_lines

for (original, sub_resource, sub_reference) in sub_resources:
    output.append(sub_resource)

for line in post_lines:
    did_write = False
    for (original, sub_resource, sub_reference) in sub_resources:
        if line.strip() == original.strip():
            did_write = True
            output.append(sub_reference)
            output.append(original)
            
    if not did_write:
        output.append(line)
        
with open('map.tscn', 'w', encoding='UTF-8', newline='\n') as f:
    f.writelines(output)