import json
import base64
import subprocess

def get_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()

article = get_file('/workspace/request-project/ARTICLE.md')
research_paper = get_file('/workspace/request-project/RESEARCH_PAPER.md')
future_directions = get_file('/workspace/request-project/FUTURE_DIRECTIONS.md')

algorithms = [
    {
        "name": "Tropical Canonicalization (Graham Scan)",
        "pseudocode": "function Canonicalize(P : List of Monomials):\n  // 1. Sort by slope ascending, then by coeff ascending\n  Sort P by (m.slope, m.coeff)\n  \n  // 2. Remove duplicates\n  Deduped = empty list\n  for m in P:\n    if Deduped is empty or Deduped.last.slope != m.slope:\n      Deduped.append(m)\n      \n  // 3. Extract Lower Convex Hull\n  Hull = empty stack\n  for p in Deduped:\n    while Hull.size >= 2:\n      p1 = Hull[second_to_last]\n      p2 = Hull[last]\n      if (p2.slope - p1.slope)*(p.coeff - p2.coeff) <= (p.slope - p2.slope)*(p2.coeff - p1.coeff):\n         Hull.pop()\n      else:\n         break\n    Hull.push(p)\n    \n  return Hull",
        "code": "def is_convex_turn(p1, p2, p3):\n    dx1 = p2.slope - p1.slope\n    dy1 = p2.coeff - p1.coeff\n    dx2 = p3.slope - p2.slope\n    dy2 = p3.coeff - p2.coeff\n    return dx1 * dy2 > dx2 * dy1\n\ndef canonicalize(terms):\n    sorted_terms = sorted(terms, key=lambda m: (m.slope, m.coeff))\n    deduped = []\n    for m in sorted_terms:\n        if not deduped or deduped[-1].slope != m.slope:\n            deduped.append(m)\n            \n    hull = []\n    for p in deduped:\n        while len(hull) >= 2 and not is_convex_turn(hull[-2], hull[-1], p):\n            hull.pop()\n        hull.append(p)\n    return hull"
    }
]

result = subprocess.run(['python3', '/workspace/request-project/gen_svg.py'], capture_output=True, text=True)
svg_data = result.stdout.strip()

demos = [
    {
        "name": "demo.py",
        "code": get_file('/workspace/request-project/demo.py')
    }
]

lean_proofs = get_file('/workspace/request-project/TropicalCanonical.lean')

output = {
    "title": "Certified Tropical Polynomial Normal Form",
    "domain": "Tropical Algebra & AI Verification",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": demos,
    "algorithms": algorithms,
    "visualizations": [
        {
            "name": "Tropical Lower Convex Hull",
            "data": svg_data
        }
    ],
    "lean_proofs": lean_proofs
}

with open('/workspace/request-project/PACKAGE.json', 'w', encoding='utf-8') as f:
    json.dump(output, f, indent=2)

print("Created PACKAGE.json")


import numpy as np
import matplotlib.pyplot as plt
from typing import List, Tuple

class TropMonomial:
    def __init__(self, coeff: float, slope: int):
        self.coeff = coeff
        self.slope = slope

    def eval(self, x: float) -> float:
        return self.coeff + self.slope * x

    def __repr__(self):
        return f"{self.slope}*x + {self.coeff}"

def is_convex_turn(p1: TropMonomial, p2: TropMonomial, p3: TropMonomial) -> bool:
    dx1 = p2.slope - p1.slope
    dy1 = p2.coeff - p1.coeff
    dx2 = p3.slope - p2.slope
    dy2 = p3.coeff - p2.coeff
    return dx1 * dy2 > dx2 * dy1

def canonicalize(terms: List[TropMonomial]) -> List[TropMonomial]:
    # Sort primarily by slope, then by coeff
    sorted_terms = sorted(terms, key=lambda m: (m.slope, m.coeff))
    
    # Dedup by slope (keep smallest coeff)
    deduped = []
    for m in sorted_terms:
        if not deduped or deduped[-1].slope != m.slope:
            deduped.append(m)
            
    # Graham scan
    hull = []
    for p in deduped:
        while len(hull) >= 2 and not is_convex_turn(hull[-2], hull[-1], p):
            hull.pop()
        hull.append(p)
        
    return hull

def plot_tropical_polynomial(terms: List[TropMonomial], title: str, filename: str):
    x = np.linspace(-5, 5, 400)
    y_min = np.full_like(x, np.inf)
    
    plt.figure(figsize=(10, 6))
    
    # Plot individual terms
    for m in terms:
        y = m.eval(x)
        y_min = np.minimum(y_min, y)
        plt.plot(x, y, '--', alpha=0.5, label=f"{m}")
        
    # Plot the minimum (tropical polynomial)
    plt.plot(x, y_min, 'k-', linewidth=3, label="Min (Tropical Poly)")
    
    plt.title(title)
    plt.xlabel('x')
    plt.ylabel('y')
    plt.grid(True)
    plt.legend()
    plt.savefig(filename)
    plt.close()

if __name__ == '__main__':
    terms = [
        TropMonomial(5, 0),
        TropMonomial(3, 1),
        TropMonomial(4, 2), # Dominated!
        TropMonomial(0, 3)
    ]
    print("Original terms:")
    for t in terms: print(t)
    
    canon = canonicalize(terms)
    print("\nCanonical terms:")
    for t in canon: print(t)
    
    plot_tropical_polynomial(terms, 'Original Polynomial', 'original.png')
    plot_tropical_polynomial(canon, 'Canonical Form', 'canonical.png')


def generate_svg():
    svg = '''<svg viewBox="0 0 800 500" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <style>
      .axis { stroke: #ccc; stroke-width: 2; }
      .line { stroke: #888; stroke-dasharray: 5,5; stroke-width: 2; fill: none; }
      .hull { stroke: #000; stroke-width: 4; fill: none; }
      .point { fill: #e74c3c; }
      .text { font-family: sans-serif; font-size: 14px; }
      .title { font-family: sans-serif; font-size: 20px; font-weight: bold; }
    </style>
  </defs>
  
  <rect width="100%" height="100%" fill="#f9f9f9" />
  
  <!-- Axes -->
  <line x1="100" y1="400" x2="700" y2="400" class="axis" />
  <line x1="400" y1="100" x2="400" y2="450" class="axis" />
  
  <!-- Original lines y = cx + b -->
  <!-- We map x from -3 to 3, to screen x 100 to 700 (scale 100) -->
  <!-- y from 0 to 10, to screen 400 to 100 (scale -30) -->
  
  <!-- Line 1: y = 5 (0x + 5) -->
  <line x1="100" y1="250" x2="700" y2="250" class="line" />
  
  <!-- Line 2: y = 1x + 3 -->
  <line x1="100" y1="400" x2="700" y2="220" class="line" />
  
  <!-- Line 3: y = 2x + 4 (dominated) -->
  <line x1="200" y1="460" x2="600" y2="160" class="line" />
  
  <!-- Line 4: y = 3x + 0 -->
  <line x1="266" y1="400" x2="533" y2="160" class="line" />
  
  <!-- Lower Envelope (Tropical Polynomial) -->
  <polyline points="100,250 400,250 500,220 533,160 600,0" class="hull" />
  
  <text x="350" y="50" class="title">Tropical Polynomial Canonicalization</text>
  <text x="410" y="420" class="text">x = 0</text>
</svg>'''
    return svg

print(generate_svg())
