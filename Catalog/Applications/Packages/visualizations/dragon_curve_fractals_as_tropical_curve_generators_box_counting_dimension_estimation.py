import numpy as np

def box_count(path, grid_size):
    boxes = set()
    for x, y in path:
        boxes.add((int(x // grid_size), int(y // grid_size)))
    return len(boxes)

def estimate_box_dimension(path, num_scales=8):
    xs = [p[0] for p in path]
    ys = [p[1] for p in path]
    ext = max(max(xs)-min(xs), max(ys)-min(ys))
    scales = [ext / (2**k) for k in range(2, 2+num_scales)]
    data = [(np.log(1/e), np.log(box_count(path, e))) for e in scales if e > 0]
    x_v = np.array([d[0] for d in data])
    y_v = np.array([d[1] for d in data])
    slope, _ = np.polyfit(x_v, y_v, 1)
    return slope

# Generate turns and path
def dragon_turns(n):
    if n == 0: return []
    prev = dragon_turns(n-1)
    return prev + [True] + [not b for b in reversed(prev)]

DIR = {0: (1,0), 1: (0,1), 2: (-1,0), 3: (0,-1)}

def dragon_path(n):
    t = dragon_turns(n)
    x, y, d = 0, 0, 0
    path = [(x, y)]
    for turn in t:
        dx, dy = DIR[d]
        x, y = x + dx, y + dy
        path.append((x, y))
        d = (d + 3) % 4 if turn else (d + 1) % 4
    dx, dy = DIR[d]
    path.append((x + dx, y + dy))
    return path

print("Box-counting dimension estimates:")
for n in [8, 10, 12, 14]:
    dim = estimate_box_dimension(dragon_path(n))
    print(f"  n={n}: dim ≈ {dim:.3f}")
print("\nDimension approaches 2 as n → ∞ (theoretical limit).")