#!/usr/bin/env python3
"""
Library of Babel: Numerical Demonstrations

Demonstrates key results:
1. Library size computation
2. Hamming distance distribution sampling
3. Incompressibility counting
4. Entropy profile computation
"""

import random
import math
from collections import Counter

# Library parameters (Borges' specification)
ALPHABET_SIZE = 25
CHARS_PER_PAGE = 3200  # 80 chars × 40 lines
NUM_PAGES = 410
BOOK_LENGTH = NUM_PAGES * CHARS_PER_PAGE  # 1,312,000

def library_size_digits():
    """Compute the number of digits in the library size 25^1312000."""
    num_digits = BOOK_LENGTH * math.log10(ALPHABET_SIZE)
    return int(num_digits) + 1

def hamming_distance(x, y):
    """Compute Hamming distance between two sequences."""
    return sum(1 for a, b in zip(x, y) if a != b)

def random_book(length=1000, alphabet_size=ALPHABET_SIZE):
    """Generate a random book (truncated for demonstration)."""
    return [random.randint(0, alphabet_size - 1) for _ in range(length)]

def demo_library_size():
    """Demonstrate the enormity of the library."""
    print("=" * 60)
    print("DEMO 1: Library Size")
    print("=" * 60)
    digits = library_size_digits()
    print(f"Alphabet size: {ALPHABET_SIZE}")
    print(f"Book length: {BOOK_LENGTH:,} characters")
    print(f"Library size: 25^{BOOK_LENGTH:,}")
    print(f"Number of digits: {digits:,}")
    print(f"For comparison: atoms in observable universe ≈ 10^80")
    print(f"Library has ~{digits:,} digits vs 80 digits for atoms")
    print(f"Ratio: 10^{digits - 80:,} times more books than atoms")
    print()

def demo_hamming_distribution(n=10000, trials=50000):
    """Sample Hamming distances between random book pairs."""
    print("=" * 60)
    print(f"DEMO 2: Hamming Distance Distribution (n={n}, {trials} trials)")
    print("=" * 60)

    expected_mean = n * (ALPHABET_SIZE - 1) / ALPHABET_SIZE
    expected_std = math.sqrt(n * (ALPHABET_SIZE - 1) / ALPHABET_SIZE**2)

    distances = []
    x = random_book(n)
    for _ in range(trials):
        y = random_book(n)
        distances.append(hamming_distance(x, y))

    actual_mean = sum(distances) / len(distances)
    actual_std = math.sqrt(sum((d - actual_mean)**2 for d in distances) / len(distances))

    print(f"Expected mean: {expected_mean:.1f}")
    print(f"Actual mean:   {actual_mean:.1f}")
    print(f"Expected std:  {expected_std:.2f}")
    print(f"Actual std:    {actual_std:.2f}")
    print(f"Fraction within 1σ: {sum(1 for d in distances if abs(d - expected_mean) <= expected_std) / trials:.3f} (expected ~0.683)")
    print(f"Fraction within 2σ: {sum(1 for d in distances if abs(d - expected_mean) <= 2*expected_std) / trials:.3f} (expected ~0.954)")
    print(f"Fraction within 3σ: {sum(1 for d in distances if abs(d - expected_mean) <= 3*expected_std) / trials:.3f} (expected ~0.997)")
    print()

def demo_incompressibility(n=20, k=4):
    """Demonstrate incompressibility by exhaustive enumeration for small parameters."""
    print("=" * 60)
    print(f"DEMO 3: Incompressibility (n={n}, k={k})")
    print("=" * 60)

    total = k ** n
    print(f"Total words of length {n} over alphabet {k}: {total:,}")

    for savings in range(1, 6):
        m = n - savings
        compressed_space = k ** m
        fraction = compressed_space / total
        print(f"  Saving {savings} chars: at most {compressed_space:,} compressible "
              f"({fraction:.2e} = {fraction*100:.6f}%)")

    print(f"\nFor the actual Library (n={BOOK_LENGTH:,}, k={ALPHABET_SIZE}):")
    for savings in [1, 10, 100, 1000]:
        log_fraction = -savings * math.log10(ALPHABET_SIZE)
        print(f"  Saving {savings:>4} chars: compressible fraction ≤ 10^{log_fraction:.1f}")
    print()

def entropy_profile(word, max_scale=None):
    """Compute the entropy profile of a word."""
    n = len(word)
    if max_scale is None:
        max_scale = min(n, 20)

    profile = {}
    for s in range(1, max_scale + 1):
        if s > n:
            break
        sgrams = set()
        for i in range(n - s + 1):
            sgrams.add(tuple(word[i:i+s]))
        profile[s] = len(sgrams)
    return profile

def demo_entropy_profile():
    """Compare entropy profiles of different types of words."""
    print("=" * 60)
    print("DEMO 4: Entropy Profiles")
    print("=" * 60)

    n = 1000
    k = 25

    # Constant word
    constant = [0] * n
    profile_const = entropy_profile(constant, 10)
    print(f"Constant word (all zeros):")
    for s, count in profile_const.items():
        max_possible = min(n - s + 1, k**s)
        print(f"  Scale {s:>2}: {count:>6} distinct s-grams (max: {max_possible})")

    # Random word
    random_word = random_book(n, k)
    profile_rand = entropy_profile(random_word, 10)
    print(f"\nRandom word:")
    for s, count in profile_rand.items():
        max_possible = min(n - s + 1, k**s)
        print(f"  Scale {s:>2}: {count:>6} distinct s-grams (max: {max_possible})")

    # Periodic word (period 5)
    periodic = [(i % 5) for i in range(n)]
    profile_periodic = entropy_profile(periodic, 10)
    print(f"\nPeriodic word (period 5):")
    for s, count in profile_periodic.items():
        max_possible = min(n - s + 1, k**s)
        print(f"  Scale {s:>2}: {count:>6} distinct s-grams (max: {max_possible})")
    print()

def demo_triangle_inequality(n=100, trials=10000):
    """Verify triangle inequality for sampled triples."""
    print("=" * 60)
    print(f"DEMO 5: Triangle Inequality Verification (n={n}, {trials} trials)")
    print("=" * 60)

    violations = 0
    tightest_ratio = float('inf')

    for _ in range(trials):
        x = random_book(n)
        y = random_book(n)
        z = random_book(n)

        dxz = hamming_distance(x, z)
        dxy = hamming_distance(x, y)
        dyz = hamming_distance(y, z)

        if dxz > dxy + dyz:
            violations += 1

        if dxy + dyz > 0:
            ratio = dxz / (dxy + dyz)
            tightest_ratio = min(tightest_ratio, 1.0 - ratio) if ratio < 1 else tightest_ratio

    print(f"Violations: {violations} / {trials}")
    print(f"Triangle inequality holds: {'YES' if violations == 0 else 'NO'}")
    print(f"Tightest margin (1 - d(x,z)/(d(x,y)+d(y,z))): {tightest_ratio:.6f}")
    print()

if __name__ == "__main__":
    random.seed(42)
    demo_library_size()
    demo_hamming_distribution()
    demo_incompressibility()
    demo_entropy_profile()
    demo_triangle_inequality()
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""Generate PACKAGE.json from all artifacts."""
import json

def read(path):
    with open(path) as f:
        return f.read()

package = {
    "title": "Library of Babel: Combinatorics of Everything",
    "domain": "Speculative",
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "future_directions": read("FUTURE_DIRECTIONS.md"),
    "demos": [
        {
            "name": "demo.py",
            "code": read("demo.py"),
            "description": "Numerical demonstrations of library size, Hamming distribution, incompressibility, entropy profiles, and triangle inequality verification."
        }
    ],
    "algorithms": [
        {
            "name": "Hamming Distance",
            "pseudocode": "For i = 1 to n: if x[i] ≠ y[i] then count += 1. Return count.",
            "code": read("algorithms.py")
        }
    ],
    "visualizations": [
        {
            "name": "Hamming Distance Distribution",
            "code": read("viz_hamming_distribution.py"),
            "description": "Histogram and Q-Q plot of Hamming distance distribution showing concentration around the mean."
        },
        {
            "name": "Entropy Profiles",
            "code": read("viz_entropy_profile.py"),
            "description": "Comparison of entropy profiles for constant, periodic, random, and structured words."
        },
        {
            "name": "Incompressibility Bound",
            "code": read("viz_incompressibility.py"),
            "description": "Exponential decay of compressible fraction and pigeonhole bound illustration."
        }
    ],
    "interactive_demos": [
        {
            "name": "Hamming Distance Explorer",
            "description": "Interactive widget to explore Hamming distance between editable strings and visualize the distance distribution.",
            "html": """<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 700px; margin: 0 auto; padding: 20px; background: #1a1a2e; color: #e0e0e0; border-radius: 12px;">
  <h2 style="color: #00d4ff; text-align: center; margin-bottom: 5px;">Hamming Distance Explorer</h2>
  <p style="text-align: center; color: #888; font-size: 13px;">Library of Babel — Edit strings to see distances change</p>
  <div style="display: flex; gap: 10px; margin: 15px 0;">
    <div style="flex: 1;">
      <label style="font-size: 12px; color: #aaa;">String A:</label>
      <input id="strA" type="text" value="HELLO WORLD OF BABEL" style="width: 100%; padding: 8px; background: #16213e; border: 1px solid #0f3460; color: #e0e0e0; border-radius: 6px; font-family: monospace;" oninput="update()">
    </div>
    <div style="flex: 1;">
      <label style="font-size: 12px; color: #aaa;">String B:</label>
      <input id="strB" type="text" value="HELLO WORLD OF BOOKS" style="width: 100%; padding: 8px; background: #16213e; border: 1px solid #0f3460; color: #e0e0e0; border-radius: 6px; font-family: monospace;" oninput="update()">
    </div>
  </div>
  <div id="result" style="text-align: center; font-size: 28px; font-weight: bold; color: #00d4ff; margin: 10px 0;"></div>
  <div id="comparison" style="font-family: monospace; font-size: 14px; line-height: 1.8; margin: 10px 0; padding: 10px; background: #16213e; border-radius: 8px; overflow-x: auto; white-space: nowrap;"></div>
  <div style="margin-top: 15px;">
    <label style="font-size: 12px; color: #aaa;">Random word length: <span id="lenLabel">50</span></label>
    <input id="lenSlider" type="range" min="10" max="200" value="50" style="width: 100%;" oninput="document.getElementById('lenLabel').textContent=this.value">
    <label style="font-size: 12px; color: #aaa;">Alphabet size: <span id="alphaLabel">25</span></label>
    <input id="alphaSlider" type="range" min="2" max="50" value="25" style="width: 100%;" oninput="document.getElementById('alphaLabel').textContent=this.value">
    <button onclick="simulate()" style="width: 100%; padding: 10px; background: #0f3460; color: #00d4ff; border: none; border-radius: 6px; font-size: 14px; cursor: pointer; margin-top: 8px;">Simulate 1000 Random Pairs</button>
  </div>
  <canvas id="chart" width="660" height="200" style="margin-top: 10px; width: 100%;"></canvas>
  <div id="stats" style="font-size: 12px; color: #aaa; text-align: center; margin-top: 5px;"></div>
  <script>
    function hammingDist(a, b) {
      let d = 0, len = Math.max(a.length, b.length);
      for (let i = 0; i < len; i++) d += (a[i] || '') !== (b[i] || '') ? 1 : 0;
      return d;
    }
    function update() {
      let a = document.getElementById('strA').value;
      let b = document.getElementById('strB').value;
      let d = hammingDist(a, b);
      let maxLen = Math.max(a.length, b.length);
      document.getElementById('result').textContent = 'Hamming Distance: ' + d + ' / ' + maxLen;
      let html = '';
      for (let i = 0; i < maxLen; i++) {
        let ca = a[i] || '·', cb = b[i] || '·';
        let match = ca === cb;
        html += '<span style="color:' + (match ? '#2ecc71' : '#e74c3c') + '">' + ca + '</span>';
      }
      html += '<br>';
      for (let i = 0; i < maxLen; i++) {
        let ca = a[i] || '·', cb = b[i] || '·';
        let match = ca === cb;
        html += '<span style="color:' + (match ? '#2ecc71' : '#e74c3c') + '">' + cb + '</span>';
      }
      document.getElementById('comparison').innerHTML = html;
    }
    function simulate() {
      let n = parseInt(document.getElementById('lenSlider').value);
      let k = parseInt(document.getElementById('alphaSlider').value);
      let dists = [];
      for (let t = 0; t < 1000; t++) {
        let d = 0;
        for (let i = 0; i < n; i++) {
          if (Math.floor(Math.random() * k) !== Math.floor(Math.random() * k)) d++;
        }
        dists.push(d);
      }
      let mean = dists.reduce((a, b) => a + b) / dists.length;
      let expMean = n * (k - 1) / k;
      let expStd = Math.sqrt(n * (k - 1) / (k * k));
      // Draw histogram
      let canvas = document.getElementById('chart');
      let ctx = canvas.getContext('2d');
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      let minD = Math.min(...dists), maxD = Math.max(...dists);
      let bins = 40, binW = (maxD - minD + 1) / bins;
      let counts = new Array(bins).fill(0);
      dists.forEach(d => { let b = Math.min(bins - 1, Math.floor((d - minD) / binW)); counts[b]++; });
      let maxC = Math.max(...counts);
      let w = canvas.width, h = canvas.height - 20;
      let barW = w / bins;
      counts.forEach((c, i) => {
        let bh = (c / maxC) * h;
        ctx.fillStyle = '#0f3460';
        ctx.fillRect(i * barW + 1, h - bh + 10, barW - 2, bh);
      });
      // Mean line
      let meanX = ((mean - minD) / (maxD - minD + 1)) * w;
      ctx.strokeStyle = '#e74c3c'; ctx.lineWidth = 2;
      ctx.beginPath(); ctx.moveTo(meanX, 10); ctx.lineTo(meanX, h + 10); ctx.stroke();
      ctx.fillStyle = '#e74c3c'; ctx.font = '11px sans-serif';
      ctx.fillText('μ=' + mean.toFixed(1), meanX + 3, 20);
      document.getElementById('stats').textContent =
        'Expected μ=' + expMean.toFixed(1) + ', σ=' + expStd.toFixed(1) +
        ' | Observed μ=' + mean.toFixed(1) + ', range=[' + minD + ',' + maxD + ']';
    }
    update();
  </script>
</div>"""
        },
        {
            "name": "Incompressibility Calculator",
            "description": "Interactive calculator showing the pigeonhole bound on compressible strings for different parameters.",
            "html": """<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; background: #1a1a2e; color: #e0e0e0; border-radius: 12px;">
  <h2 style="color: #ff6b6b; text-align: center;">Incompressibility Calculator</h2>
  <p style="text-align: center; color: #888; font-size: 13px;">Pigeonhole Principle: Most strings cannot be compressed</p>
  <div style="margin: 15px 0;">
    <label style="color: #aaa;">Word length n = <span id="nVal">100</span></label>
    <input id="nSlider" type="range" min="5" max="500" value="100" style="width: 100%;" oninput="calc()">
    <label style="color: #aaa;">Alphabet size k = <span id="kVal">25</span></label>
    <input id="kSlider" type="range" min="2" max="100" value="25" style="width: 100%;" oninput="calc()">
    <label style="color: #aaa;">Savings s = <span id="sVal">1</span> characters</label>
    <input id="sSlider" type="range" min="0" max="50" value="1" style="width: 100%;" oninput="calc()">
  </div>
  <div id="output" style="background: #16213e; padding: 15px; border-radius: 8px; margin: 10px 0;"></div>
  <canvas id="bar" width="560" height="60" style="width: 100%; margin-top: 10px;"></canvas>
  <div id="barLabel" style="text-align: center; font-size: 11px; color: #888;"></div>
  <script>
    function calc() {
      let n = parseInt(document.getElementById('nSlider').value);
      let k = parseInt(document.getElementById('kSlider').value);
      let s = parseInt(document.getElementById('sSlider').value);
      document.getElementById('nVal').textContent = n;
      document.getElementById('kVal').textContent = k;
      document.getElementById('sVal').textContent = s;
      let logTotal = n * Math.log10(k);
      let logComp = (n - s) * Math.log10(k);
      let logFrac = -s * Math.log10(k);
      let frac = Math.pow(10, logFrac);
      let pct = (frac * 100);
      let html = '<div style="font-size: 14px; line-height: 2;">';
      html += '<b>Total words:</b> ' + k + '<sup>' + n + '</sup> ≈ 10<sup>' + logTotal.toFixed(1) + '</sup><br>';
      html += '<b>Max compressible:</b> ' + k + '<sup>' + (n-s) + '</sup> ≈ 10<sup>' + logComp.toFixed(1) + '</sup><br>';
      html += '<b>Compressible fraction:</b> ≤ ' + (frac < 0.001 ? '10<sup>' + logFrac.toFixed(1) + '</sup>' : pct.toFixed(4) + '%') + '<br>';
      html += '<b>Incompressible fraction:</b> ≥ ' + (1-frac > 0.999 ? (100*(1-frac)).toFixed(6) + '%' : ((1-frac)*100).toFixed(2) + '%') + '<br>';
      html += '<b style="color: #ff6b6b;">Majority incompressible?</b> ' + (frac < 0.5 ? '<span style="color:#2ecc71">YES ✓</span>' : '<span style="color:#e74c3c">NO ✗</span>');
      html += '</div>';
      document.getElementById('output').innerHTML = html;
      // Draw bar
      let canvas = document.getElementById('bar');
      let ctx = canvas.getContext('2d');
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      let compW = Math.max(1, Math.min(canvas.width, frac * canvas.width));
      ctx.fillStyle = '#3498db'; ctx.fillRect(0, 0, compW, canvas.height);
      ctx.fillStyle = '#e74c3c'; ctx.fillRect(compW, 0, canvas.width - compW, canvas.height);
      document.getElementById('barLabel').textContent = 'Blue = compressible, Red = incompressible';
    }
    calc();
  </script>
</div>"""
        },
        {
            "name": "Entropy Profile Visualizer",
            "description": "Interactive tool to type a string and see its entropy profile across scales.",
            "html": """<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 650px; margin: 0 auto; padding: 20px; background: #1a1a2e; color: #e0e0e0; border-radius: 12px;">
  <h2 style="color: #2ecc71; text-align: center;">Entropy Profile Visualizer</h2>
  <p style="text-align: center; color: #888; font-size: 13px;">Multi-scale complexity of a string</p>
  <textarea id="input" rows="3" style="width: 100%; padding: 8px; background: #16213e; border: 1px solid #0f3460; color: #e0e0e0; border-radius: 6px; font-family: monospace; resize: vertical;" oninput="analyze()">THE LIBRARY OF BABEL CONTAINS ALL POSSIBLE BOOKS INCLUDING THIS ONE</textarea>
  <div style="margin: 10px 0;">
    <button onclick="document.getElementById('input').value='AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';analyze()" style="padding: 5px 10px; background: #0f3460; color: #aaa; border: none; border-radius: 4px; cursor: pointer; margin: 2px;">Constant</button>
    <button onclick="document.getElementById('input').value='ABCABCABCABCABCABCABCABCABCABCABCABCABC';analyze()" style="padding: 5px 10px; background: #0f3460; color: #aaa; border: none; border-radius: 4px; cursor: pointer; margin: 2px;">Periodic</button>
    <button onclick="let s='';for(let i=0;i<60;i++)s+=String.fromCharCode(65+Math.floor(Math.random()*26));document.getElementById('input').value=s;analyze()" style="padding: 5px 10px; background: #0f3460; color: #aaa; border: none; border-radius: 4px; cursor: pointer; margin: 2px;">Random</button>
  </div>
  <canvas id="profileChart" width="610" height="250" style="width: 100%;"></canvas>
  <div id="profileStats" style="font-size: 12px; color: #aaa; margin-top: 5px;"></div>
  <script>
    function analyze() {
      let text = document.getElementById('input').value;
      let n = text.length;
      if (n < 2) return;
      let alphabet = new Set(text.split('')).size;
      let maxScale = Math.min(n - 1, 15);
      let profile = [], maxPossible = [];
      for (let s = 1; s <= maxScale; s++) {
        let grams = new Set();
        for (let i = 0; i <= n - s; i++) grams.add(text.substring(i, i + s));
        profile.push(grams.size);
        maxPossible.push(Math.min(n - s + 1, Math.pow(alphabet, s)));
      }
      // Draw
      let canvas = document.getElementById('profileChart');
      let ctx = canvas.getContext('2d');
      let W = canvas.width, H = canvas.height;
      ctx.clearRect(0, 0, W, H);
      let maxV = Math.max(...maxPossible, ...profile);
      let useLog = maxV > 100;
      let toY = v => H - 30 - (useLog ? (Math.log(v + 1) / Math.log(maxV + 1)) : (v / maxV)) * (H - 50);
      let toX = i => 40 + i * ((W - 60) / (maxScale - 1));
      // Axes
      ctx.strokeStyle = '#333'; ctx.lineWidth = 1;
      ctx.beginPath(); ctx.moveTo(40, 10); ctx.lineTo(40, H - 30); ctx.lineTo(W - 10, H - 30); ctx.stroke();
      // Max possible line
      ctx.strokeStyle = '#555'; ctx.lineWidth = 1; ctx.setLineDash([5, 3]);
      ctx.beginPath();
      for (let i = 0; i < maxScale; i++) {
        let x = toX(i), y = toY(maxPossible[i]);
        i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
      }
      ctx.stroke(); ctx.setLineDash([]);
      // Profile line
      ctx.strokeStyle = '#2ecc71'; ctx.lineWidth = 2.5;
      ctx.beginPath();
      for (let i = 0; i < maxScale; i++) {
        let x = toX(i), y = toY(profile[i]);
        i === 0 ? ctx.moveTo(x, y) : ctx.lineTo(x, y);
      }
      ctx.stroke();
      // Points
      for (let i = 0; i < maxScale; i++) {
        ctx.fillStyle = '#2ecc71';
        ctx.beginPath(); ctx.arc(toX(i), toY(profile[i]), 4, 0, 2 * Math.PI); ctx.fill();
      }
      // Labels
      ctx.fillStyle = '#888'; ctx.font = '11px sans-serif';
      for (let i = 0; i < maxScale; i++) {
        ctx.fillText(i + 1, toX(i) - 3, H - 15);
      }
      ctx.fillStyle = '#aaa'; ctx.font = '12px sans-serif';
      ctx.fillText('Scale s', W / 2 - 20, H - 2);
      ctx.save(); ctx.translate(12, H / 2); ctx.rotate(-Math.PI / 2);
      ctx.fillText('Distinct s-grams' + (useLog ? ' (log)' : ''), -40, 0); ctx.restore();
      document.getElementById('profileStats').textContent =
        'Length: ' + n + ' | Alphabet: ' + alphabet + ' distinct chars | Green = actual, Gray dashed = maximum possible';
    }
    analyze();
  </script>
</div>"""
        }
    ],
    "lean_proofs": [
        {
            "name": "LibraryOfBabel.Defs",
            "file": "Speculative/AutoResearch/LibraryOfBabel/Defs.lean",
            "theorems": [
                "hammingDist_symm",
                "hammingDist_eq_zero_iff",
                "hammingDist_triangle",
                "hammingDist_le_length",
                "compressible_card_le",
                "majority_incompressible",
                "hammingBall_zero_card",
                "hammingBall_full",
                "singleton_clopen_of_discrete",
                "totallyDisconnected_of_discrete",
                "babelBook_connected_components_singletons",
                "babelBook_card",
                "babelBook_maxDist"
            ]
        }
    ]
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")


#!/usr/bin/env python3
"""
Visualization: Entropy Profiles

Compares entropy profiles of constant, periodic, and random words,
showing how multi-scale complexity differs across word types.
"""

import random
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def entropy_profile(word, max_scale=15):
    n = len(word)
    profile = {}
    for s in range(1, min(max_scale + 1, n + 1)):
        sgrams = set()
        for i in range(n - s + 1):
            sgrams.add(tuple(word[i:i + s]))
        profile[s] = len(sgrams)
    return profile


def max_possible(n, k, s):
    return min(n - s + 1, k ** s)


def main():
    random.seed(42)
    n = 500
    k = 10
    max_s = 12

    # Generate words
    constant_word = [0] * n
    periodic_word = [(i % 3) for i in range(n)]
    random_word = [random.randint(0, k-1) for _ in range(n)]
    structured_word = [i % k for i in range(n)]  # sequential cycling

    words = {
        'Constant (aaaa...)': constant_word,
        'Periodic (period 3)': periodic_word,
        'Random': random_word,
        'Sequential cycling': structured_word,
    }

    colors = ['#e74c3c', '#f39c12', '#2ecc71', '#3498db']

    fig, ax = plt.subplots(figsize=(10, 6))

    for (name, word), color in zip(words.items(), colors):
        profile = entropy_profile(word, max_s)
        scales = sorted(profile.keys())
        values = [profile[s] for s in scales]
        ax.plot(scales, values, 'o-', color=color, linewidth=2, markersize=6, label=name)

    # Maximum possible
    scales = list(range(1, max_s + 1))
    max_vals = [max_possible(n, k, s) for s in scales]
    ax.plot(scales, max_vals, 'k--', linewidth=1.5, alpha=0.5, label='Maximum possible')

    ax.set_xlabel('Scale s (s-gram length)', fontsize=13)
    ax.set_ylabel('Distinct s-grams', fontsize=13)
    ax.set_title(f'Entropy Profile Comparison\n(n={n}, alphabet size k={k})', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_yscale('log')
    ax.set_xticks(scales)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('entropy_profiles.png', dpi=150, bbox_inches='tight')
    print("Saved entropy_profiles.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Hamming Distance Distribution

Plots the distribution of Hamming distances between a fixed word
and random words, showing concentration around the mean.
"""

import random
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def hamming_distance(x, y):
    return sum(1 for a, b in zip(x, y) if a != b)


def main():
    random.seed(42)
    n = 5000  # word length
    k = 25    # alphabet size
    trials = 100000

    expected_mean = n * (k - 1) / k
    expected_std = math.sqrt(n * (k - 1) / k**2)

    x = [random.randint(0, k-1) for _ in range(n)]
    distances = []
    for _ in range(trials):
        y = [random.randint(0, k-1) for _ in range(n)]
        distances.append(hamming_distance(x, y))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Histogram
    ax1 = axes[0]
    ax1.hist(distances, bins=80, density=True, alpha=0.7, color='steelblue',
             edgecolor='white', linewidth=0.5, label='Observed')

    # Theoretical normal approximation
    xs = np.linspace(min(distances), max(distances), 200)
    normal_pdf = (1 / (expected_std * math.sqrt(2 * math.pi))) * \
                 np.exp(-0.5 * ((xs - expected_mean) / expected_std)**2)
    ax1.plot(xs, normal_pdf, 'r-', linewidth=2, label='Normal approximation')

    ax1.axvline(expected_mean, color='darkred', linestyle='--', linewidth=1.5,
                label=f'Mean = {expected_mean:.0f}')
    ax1.set_xlabel('Hamming Distance', fontsize=12)
    ax1.set_ylabel('Density', fontsize=12)
    ax1.set_title(f'Hamming Distance Distribution\n(n={n}, k={k}, {trials:,} samples)',
                  fontsize=13)
    ax1.legend(fontsize=10)

    # Q-Q plot (standardized)
    ax2 = axes[1]
    sorted_z = np.sort([(d - expected_mean) / expected_std for d in distances])
    theoretical_q = np.array([
        -math.sqrt(2) * math.erfc(2 * (i + 0.5) / len(sorted_z)) 
        for i in range(len(sorted_z))
    ]) if False else np.linspace(-4, 4, len(sorted_z))

    # Use scipy-free Q-Q: plot sorted standardized values against expected normal quantiles
    n_pts = len(sorted_z)
    expected_quantiles = [_normal_quantile((i + 0.5) / n_pts) for i in range(n_pts)]
    
    # Subsample for plotting
    step = max(1, n_pts // 2000)
    ax2.scatter(expected_quantiles[::step], sorted_z[::step], s=1, alpha=0.5, color='steelblue')
    ax2.plot([-4, 4], [-4, 4], 'r-', linewidth=1.5, label='y = x (perfect normal)')
    ax2.set_xlabel('Theoretical Quantiles', fontsize=12)
    ax2.set_ylabel('Observed Quantiles', fontsize=12)
    ax2.set_title('Q-Q Plot (Normal)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_xlim(-4, 4)
    ax2.set_ylim(-4, 4)

    plt.tight_layout()
    plt.savefig('hamming_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved hamming_distribution.png")


def _normal_quantile(p):
    """Approximate inverse normal CDF using rational approximation."""
    if p <= 0:
        return -8.0
    if p >= 1:
        return 8.0
    if p == 0.5:
        return 0.0
    if p > 0.5:
        return -_normal_quantile(1 - p)
    
    t = math.sqrt(-2 * math.log(p))
    c0, c1, c2 = 2.515517, 0.802853, 0.010328
    d1, d2, d3 = 1.432788, 0.189269, 0.001308
    return -(t - (c0 + c1*t + c2*t**2) / (1 + d1*t + d2*t**2 + d3*t**3))


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Incompressibility Bound

Shows how the fraction of compressible words drops exponentially
as the compression savings increase.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Compressible fraction vs savings for different alphabet sizes
    ax1 = axes[0]
    n = 100  # word length
    savings_range = range(0, 50)

    for k, color, marker in [(2, '#e74c3c', 'o'), (4, '#3498db', 's'),
                              (10, '#2ecc71', '^'), (25, '#9b59b6', 'D')]:
        fractions = []
        for s in savings_range:
            frac = k ** (-s) if s > 0 else 1.0
            fractions.append(frac)
        ax1.plot(list(savings_range), fractions, f'{marker}-', color=color,
                 linewidth=1.5, markersize=4, label=f'k={k}', markevery=5)

    ax1.set_xlabel('Compression savings (characters)', fontsize=12)
    ax1.set_ylabel('Max compressible fraction', fontsize=12)
    ax1.set_title(f'Compressible Fraction vs Savings\n(n={n})', fontsize=13)
    ax1.set_yscale('log')
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(1e-60, 2)

    # Plot 2: Pigeonhole illustration for small parameters
    ax2 = axes[1]
    n_small = 8
    k_small = 3
    total = k_small ** n_small

    savings_vals = list(range(0, n_small + 1))
    compressible = [min(total, k_small ** (n_small - s)) for s in savings_vals]
    incompressible = [total - c for c in compressible]

    x = np.arange(len(savings_vals))
    width = 0.35
    bars1 = ax2.bar(x - width/2, compressible, width, color='#3498db',
                    alpha=0.8, label='Compressible (upper bound)')
    bars2 = ax2.bar(x + width/2, incompressible, width, color='#e74c3c',
                    alpha=0.8, label='Incompressible (lower bound)')

    ax2.set_xlabel('Compression savings', fontsize=12)
    ax2.set_ylabel('Number of words', fontsize=12)
    ax2.set_title(f'Pigeonhole Bound\n(n={n_small}, k={k_small}, total={total})',
                  fontsize=13)
    ax2.set_xticks(x)
    ax2.set_xticklabels(savings_vals)
    ax2.legend(fontsize=10)
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('incompressibility.png', dpi=150, bbox_inches='tight')
    print("Saved incompressibility.png")


if __name__ == "__main__":
    main()
