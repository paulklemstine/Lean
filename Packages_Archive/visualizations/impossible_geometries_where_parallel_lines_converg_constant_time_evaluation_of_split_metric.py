from math import cosh, sinh

def invariants(x: float, y: float) -> dict[str, float]:
    cx, cy, sy = cosh(x), cosh(y), sinh(y)
    return {"g11": 1/cy**2, "g22": cx**2, "density": cx/cy,
            "curvature": -cy**2 + (1-sy**2)/(cx**2*cy**2)}

for p in [(0,0), (1,0), (0,1), (1,1)]:
    print(p, invariants(*p))
