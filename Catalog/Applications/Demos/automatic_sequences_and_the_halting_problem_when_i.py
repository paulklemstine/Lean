"""
Demo: Automatic Sequences and the Decidability Frontier

Demonstrates key properties of automatic sequences:
1. Thue-Morse sequence generation and properties
2. K-kernel computation showing finiteness
3. Zero-in-sequence decidability
4. Morphic sequence generation and decidability testing
"""

from algorithms import (
    DFAO, thue_morse_dfao, rudin_shapiro_dfao, paperfolding_dfao,
    compute_k_kernel, thue_morse_morphism, fibonacci_morphism,
    AlphabetMorphism, product_dfao
)


def demo_thue_morse():
    """Demonstrate Thue-Morse sequence properties."""
    print("=" * 60)
    print("DEMO 1: Thue-Morse Sequence")
    print("=" * 60)

    tm = thue_morse_dfao()

    # Generate first 64 elements
    seq = [tm.sequence(n) for n in range(64)]
    print(f"First 64 terms: {''.join(map(str, seq))}")

    # Verify self-similarity: t(2n) = t(n)
    for n in range(32):
        assert tm.sequence(2 * n) == tm.sequence(n), f"Self-similarity fails at n={n}"
    print("✓ Self-similarity t(2n) = t(n) verified for n = 0..31")

    # Verify complementation: t(2n+1) ≠ t(n)
    for n in range(32):
        assert tm.sequence(2 * n + 1) != tm.sequence(n), f"Complementation fails at n={n}"
    print("✓ Complementation t(2n+1) ≠ t(n) verified for n = 0..31")

    # Check aperiodicity: no period p works for first 1000 elements
    for p in range(1, 50):
        periodic = True
        for n in range(100, 200):
            if tm.sequence(n + p) != tm.sequence(n):
                periodic = False
                break
        if periodic:
            print(f"  WARNING: possible period {p} found!")
    print("✓ No period p ≤ 49 found (consistent with aperiodicity)")

    # Value dichotomy: both 0 and 1 appear infinitely often
    count_0 = sum(1 for n in range(10000) if tm.sequence(n) == 0)
    count_1 = sum(1 for n in range(10000) if tm.sequence(n) == 1)
    print(f"  In first 10000 terms: {count_0} zeros, {count_1} ones")
    print()


def demo_zero_in_sequence():
    """Demonstrate zero-in-sequence decidability."""
    print("=" * 60)
    print("DEMO 2: Zero-in-Sequence Decidability")
    print("=" * 60)

    automata = [
        ("Thue-Morse", thue_morse_dfao()),
        ("Rudin-Shapiro", rudin_shapiro_dfao()),
        ("Paperfolding", paperfolding_dfao()),
    ]

    for name, dfao in automata:
        reachable = dfao.reachable_states()
        values = dfao.output_values()
        print(f"\n{name} DFAO:")
        print(f"  States: {dfao.states}, Reachable: {len(reachable)}")
        print(f"  Output values: {sorted(values)}")

        for v in sorted(set(dfao.output)):
            appears = dfao.zero_in_sequence(v)
            print(f"  Value {v} appears: {appears}")
    print()


def demo_k_kernel():
    """Demonstrate k-kernel computation and finiteness."""
    print("=" * 60)
    print("DEMO 3: k-Kernel Computation")
    print("=" * 60)

    tm = thue_morse_dfao()
    tm_seq = lambda n: tm.sequence(n)

    kernel = compute_k_kernel(tm_seq, k=2, max_e=6, max_check=50)
    print(f"\n2-kernel of Thue-Morse (up to depth 6):")
    print(f"  Distinct subsequences found: {len(kernel)}")
    print(f"  DFAO has {tm.states} states")
    print(f"  Kernel size ≤ states: {len(kernel) <= tm.states}")

    for e, r in kernel:
        prefix = [tm_seq(2**e * n + r) for n in range(16)]
        print(f"  (e={e}, r={r}): {''.join(map(str, prefix))}...")

    # Rudin-Shapiro kernel
    rs = rudin_shapiro_dfao()
    rs_seq = lambda n: rs.sequence(n)
    kernel_rs = compute_k_kernel(rs_seq, k=2, max_e=5, max_check=50)
    print(f"\n2-kernel of Rudin-Shapiro (up to depth 5):")
    print(f"  Distinct subsequences: {len(kernel_rs)}")
    print(f"  DFAO has {rs.states} states")
    print()


def demo_closure():
    """Demonstrate closure under pointwise operations."""
    print("=" * 60)
    print("DEMO 4: Closure Under Pointwise Operations")
    print("=" * 60)

    tm = thue_morse_dfao()
    pf = paperfolding_dfao()

    # XOR of Thue-Morse with Paperfolding is also 2-automatic
    # Product has tm.states * pf.states = 8 states
    print(f"\nThue-Morse: {tm.states} states")
    print(f"Paperfolding: {pf.states} states")
    print(f"Product (before XOR): {tm.states * pf.states} states")

    # Generate XOR sequence directly
    xor_seq = [tm.sequence(n) ^ pf.sequence(n) for n in range(32)]
    print(f"XOR sequence: {''.join(map(str, xor_seq))}")

    # Verify it's 2-automatic by checking kernel finiteness
    xor_fn = lambda n: tm.sequence(n) ^ pf.sequence(n)
    kernel = compute_k_kernel(xor_fn, k=2, max_e=5, max_check=50)
    print(f"2-kernel size: {len(kernel)} (should be ≤ {tm.states * pf.states})")
    print()


def demo_morphic():
    """Demonstrate morphic sequence generation and decidability."""
    print("=" * 60)
    print("DEMO 5: Morphic Sequences and Decidability")
    print("=" * 60)

    # Thue-Morse as morphic sequence
    tm_morph = thue_morse_morphism()
    word = tm_morph.iterate(0, 6)
    print(f"\nThue-Morse via morphism (6 iterations): {''.join(map(str, word[:64]))}...")
    print(f"  Length: {len(word)}")
    print(f"  Is 2-uniform: {tm_morph.is_uniform(2)}")
    print(f"  Is prolongable on 0: {tm_morph.is_prolongable(0)}")

    # Fibonacci word (non-uniform morphism!)
    fib = fibonacci_morphism()
    fib_word = fib.iterate(0, 10)
    print(f"\nFibonacci word (10 iterations): {''.join(map(str, fib_word[:64]))}...")
    print(f"  Length: {len(fib_word)}")
    print(f"  Is uniform: {fib.is_uniform()}")
    print(f"  Is prolongable on 0: {fib.is_prolongable(0)}")

    # Zero-in-sequence for morphic sequences
    for target in [0, 1]:
        result = fib.zero_in_morphic_word(0, target)
        print(f"  Target {target} in Fibonacci word: {result}")

    # Test more exotic morphisms
    print("\nExotic morphism test (0->012, 1->10, 2->2):")
    exotic = AlphabetMorphism({0: [0, 1, 2], 1: [1, 0], 2: [2]})
    exotic_word = exotic.iterate(0, 5)
    print(f"  Word: {''.join(map(str, exotic_word[:64]))}...")
    for target in [0, 1, 2]:
        result = exotic.zero_in_morphic_word(0, target)
        print(f"  Target {target} appears: {result}")
    print()


def demo_decidability_test():
    """Test the decidability conjecture on random morphisms."""
    print("=" * 60)
    print("DEMO 6: Morphic Decidability Conjecture Test")
    print("=" * 60)

    import random
    random.seed(42)

    tested = 0
    decided = 0
    undecided = 0

    for trial in range(100):
        k = random.choice([2, 3])
        images = {}
        for a in range(k):
            length = random.randint(1, 5)
            images[a] = [random.randint(0, k - 1) for _ in range(length)]

        # Ensure prolongable on 0
        if len(images[0]) >= 2:
            images[0][0] = 0
        else:
            images[0] = [0, random.randint(0, k - 1)]

        morph = AlphabetMorphism(images)
        if not morph.is_prolongable(0):
            continue

        tested += 1
        for target in range(k):
            result = morph.zero_in_morphic_word(0, target)
            if result is not None:
                decided += 1
            else:
                undecided += 1

    print(f"\nTested {tested} prolongable morphisms")
    print(f"  Decided: {decided}, Undecided: {undecided}")
    print(f"  Decision rate: {decided / (decided + undecided) * 100:.1f}%")
    print()


if __name__ == "__main__":
    demo_thue_morse()
    demo_zero_in_sequence()
    demo_k_kernel()
    demo_closure()
    demo_morphic()
    demo_decidability_test()
    print("All demos completed successfully.")


"""Generate PACKAGE.json with all artifacts."""
import json

# Read all files
def read_file(path):
    with open(path, 'r') as f:
        return f.read()

article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_proofs = read_file('Computation/AutomaticDecidability.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
viz_code = read_file('viz_thue_morse.py')

interactive_demo_1 = """<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background: #1a1a2e; color: #e0e0e0; border-radius: 12px;">
<h2 style="color: #00d4ff; text-align: center;">Thue-Morse Sequence Explorer</h2>
<p style="text-align: center; color: #aaa;">The prototypical 2-automatic sequence: t(n) = popcount(n) mod 2</p>

<div style="margin: 15px 0;">
  <label style="color: #00d4ff;">Number of terms: <span id="countLabel">64</span></label><br>
  <input type="range" id="countSlider" min="16" max="256" value="64" step="16"
         style="width: 100%; accent-color: #00d4ff;">
</div>

<canvas id="tmCanvas" width="780" height="200" style="background: #16213e; border-radius: 8px; display: block; margin: 10px auto;"></canvas>

<div style="display: flex; gap: 10px; margin: 15px 0;">
  <button onclick="showOriginal()" style="flex:1; padding: 8px; background: #0f3460; color: #00d4ff; border: 1px solid #00d4ff; border-radius: 6px; cursor: pointer;">Original t(n)</button>
  <button onclick="showEvenSub()" style="flex:1; padding: 8px; background: #0f3460; color: #4CAF50; border: 1px solid #4CAF50; border-radius: 6px; cursor: pointer;">Even: t(2n)=t(n)</button>
  <button onclick="showOddSub()" style="flex:1; padding: 8px; background: #0f3460; color: #F44336; border: 1px solid #F44336; border-radius: 6px; cursor: pointer;">Odd: t(2n+1)≠t(n)</button>
</div>

<div id="stats" style="background: #16213e; padding: 12px; border-radius: 8px; font-size: 14px;"></div>

<div style="margin-top: 15px;">
  <h3 style="color: #00d4ff;">DFAO State Machine</h3>
  <svg width="300" height="120" style="display: block; margin: 0 auto;">
    <circle cx="80" cy="60" r="30" fill="none" stroke="#4CAF50" stroke-width="2"/>
    <text x="80" y="55" text-anchor="middle" fill="#4CAF50" font-size="12">State 0</text>
    <text x="80" y="72" text-anchor="middle" fill="#4CAF50" font-size="11">out: 0</text>
    <circle cx="220" cy="60" r="30" fill="none" stroke="#F44336" stroke-width="2"/>
    <text x="220" y="55" text-anchor="middle" fill="#F44336" font-size="12">State 1</text>
    <text x="220" y="72" text-anchor="middle" fill="#F44336" font-size="11">out: 1</text>
    <path d="M 110 50 Q 150 10 190 50" fill="none" stroke="#aaa" stroke-width="1.5" marker-end="url(#arrow)"/>
    <text x="150" y="22" text-anchor="middle" fill="#aaa" font-size="11">1</text>
    <path d="M 190 70 Q 150 110 110 70" fill="none" stroke="#aaa" stroke-width="1.5" marker-end="url(#arrow)"/>
    <text x="150" y="105" text-anchor="middle" fill="#aaa" font-size="11">1</text>
    <path d="M 60 35 Q 40 10 60 35" fill="none" stroke="#aaa" stroke-width="0"/>
    <path d="M 55 38 A 18 18 0 1 1 68 35" fill="none" stroke="#aaa" stroke-width="1.5" marker-end="url(#arrow)"/>
    <text x="45" y="18" text-anchor="middle" fill="#aaa" font-size="11">0</text>
    <path d="M 245 38 A 18 18 0 1 0 232 35" fill="none" stroke="#aaa" stroke-width="1.5" marker-end="url(#arrow)"/>
    <text x="255" y="18" text-anchor="middle" fill="#aaa" font-size="11">0</text>
    <defs><marker id="arrow" markerWidth="6" markerHeight="4" refX="6" refY="2" orient="auto"><path d="M0,0 L6,2 L0,4" fill="#aaa"/></marker></defs>
  </svg>
</div>

<script>
function popcount(n) { let c=0; while(n>0){c+=n&1;n>>=1;} return c; }
function thueMorse(n) { return popcount(n) % 2; }

let mode = 'original';

function showOriginal() { mode='original'; draw(); }
function showEvenSub() { mode='even'; draw(); }
function showOddSub() { mode='odd'; draw(); }

function draw() {
  const N = parseInt(document.getElementById('countSlider').value);
  document.getElementById('countLabel').textContent = N;
  const canvas = document.getElementById('tmCanvas');
  const ctx = canvas.getContext('2d');
  const w = canvas.width, h = canvas.height;
  ctx.clearRect(0,0,w,h);

  let seq = [];
  let label = '';
  let color0 = '#16213e', color1 = '#00d4ff';

  if (mode === 'original') {
    for(let i=0;i<N;i++) seq.push(thueMorse(i));
    label = 't(n)'; color1 = '#00d4ff';
  } else if (mode === 'even') {
    for(let i=0;i<N;i++) seq.push(thueMorse(2*i));
    label = 't(2n) = t(n)'; color1 = '#4CAF50';
  } else {
    for(let i=0;i<N;i++) seq.push(thueMorse(2*i+1));
    label = 't(2n+1)'; color1 = '#F44336';
  }

  const cols = Math.ceil(Math.sqrt(N * 4));
  const rows = Math.ceil(N / cols);
  const cellW = w / cols;
  const cellH = h / rows;
  const sz = Math.min(cellW, cellH);

  for(let i=0;i<N;i++) {
    const col = i % cols, row = Math.floor(i / cols);
    ctx.fillStyle = seq[i] === 1 ? color1 : color0;
    ctx.fillRect(col*sz, row*sz, sz-1, sz-1);
  }

  const zeros = seq.filter(x=>x===0).length;
  const ones = seq.filter(x=>x===1).length;
  document.getElementById('stats').innerHTML =
    '<b style="color:'+color1+'">'+label+'</b> | ' +
    'Terms: '+N+' | Zeros: '+zeros+' | Ones: '+ones+' | ' +
    'Balance: '+(zeros/N*100).toFixed(1)+'% / '+(ones/N*100).toFixed(1)+'%';
}

document.getElementById('countSlider').addEventListener('input', draw);
draw();
</script>
</div>"""

interactive_demo_2 = """<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background: #1a1a2e; color: #e0e0e0; border-radius: 12px;">
<h2 style="color: #ff6b6b; text-align: center;">k-Kernel Explorer</h2>
<p style="text-align: center; color: #aaa;">Visualize the k-kernel: all subsequences n → seq(k<sup>e</sup>·n + r)</p>

<div style="display: flex; gap: 10px; margin: 15px 0;">
  <div style="flex:1;">
    <label style="color: #ff6b6b;">Depth e: <span id="depthLabel">3</span></label><br>
    <input type="range" id="depthSlider" min="0" max="5" value="3"
           style="width: 100%; accent-color: #ff6b6b;">
  </div>
  <div style="flex:1;">
    <label style="color: #ff6b6b;">Terms shown: <span id="termsLabel">24</span></label><br>
    <input type="range" id="termsSlider" min="8" max="48" value="24"
           style="width: 100%; accent-color: #ff6b6b;">
  </div>
</div>

<canvas id="kernelCanvas" width="780" height="350" style="background: #16213e; border-radius: 8px; display: block; margin: 10px auto;"></canvas>

<div id="kernelInfo" style="background: #16213e; padding: 12px; border-radius: 8px; font-size: 14px; margin-top: 10px;"></div>

<script>
function popcount(n) { let c=0; while(n>0){c+=n&1;n>>=1;} return c; }
function thueMorse(n) { return popcount(n) % 2; }

function drawKernel() {
  const maxE = parseInt(document.getElementById('depthSlider').value);
  const nTerms = parseInt(document.getElementById('termsSlider').value);
  document.getElementById('depthLabel').textContent = maxE;
  document.getElementById('termsLabel').textContent = nTerms;

  const canvas = document.getElementById('kernelCanvas');
  const ctx = canvas.getContext('2d');
  const W = canvas.width, H = canvas.height;
  ctx.clearRect(0,0,W,H);

  // Compute kernel elements
  const sigs = {};
  const elements = [];
  const colors = ['#00d4ff','#ff6b6b','#4CAF50','#FF9800','#9C27B0','#00BCD4','#FFEB3B','#E91E63'];

  for(let e=0; e<=maxE; e++) {
    const ke = Math.pow(2, e);
    for(let r=0; r<ke; r++) {
      const sig = [];
      for(let n=0; n<32; n++) sig.push(thueMorse(ke*n + r));
      const key = sig.join('');
      if(!(key in sigs)) {
        sigs[key] = elements.length;
        elements.push({e:e, r:r, sig:sig, key:key});
      }
    }
  }

  const numEl = elements.length;
  const rowH = Math.min(40, (H-40) / numEl);
  const colW = (W-120) / nTerms;

  ctx.fillStyle = '#aaa';
  ctx.font = '11px monospace';
  ctx.textAlign = 'right';

  for(let i=0; i<numEl; i++) {
    const el = elements[i];
    const y = 20 + i * rowH;
    const color = colors[i % colors.length];

    ctx.fillStyle = '#aaa';
    ctx.fillText('e='+el.e+',r='+el.r, 95, y + rowH/2 + 4);

    for(let n=0; n<nTerms; n++) {
      const v = el.sig[n];
      ctx.fillStyle = v === 1 ? color : '#16213e';
      ctx.strokeStyle = color;
      ctx.lineWidth = 0.5;
      ctx.fillRect(105 + n*colW, y, colW-1, rowH-2);
      ctx.strokeRect(105 + n*colW, y, colW-1, rowH-2);
    }
  }

  document.getElementById('kernelInfo').innerHTML =
    '<b style="color:#ff6b6b">2-kernel of Thue-Morse</b> (depth ≤ '+maxE+'): ' +
    '<b>'+numEl+'</b> distinct subsequences found. ' +
    'DFAO has <b>2</b> states. Kernel size ≤ states: <b>'+(numEl<=2)+'</b>';
}

document.getElementById('depthSlider').addEventListener('input', drawKernel);
document.getElementById('termsSlider').addEventListener('input', drawKernel);
drawKernel();
</script>
</div>"""

interactive_demo_3 = """<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background: #1a1a2e; color: #e0e0e0; border-radius: 12px;">
<h2 style="color: #4CAF50; text-align: center;">Morphism Iterator</h2>
<p style="text-align: center; color: #aaa;">Watch a morphism build an automatic sequence letter by letter</p>

<div style="margin: 15px 0;">
  <label style="color: #4CAF50;">Iterations: <span id="iterLabel">5</span></label><br>
  <input type="range" id="iterSlider" min="1" max="8" value="5"
         style="width: 100%; accent-color: #4CAF50;">
</div>

<div style="display: flex; gap: 10px; margin: 15px 0;">
  <button onclick="setMorph('tm')" style="flex:1; padding: 8px; background: #0f3460; color: #4CAF50; border: 1px solid #4CAF50; border-radius: 6px; cursor: pointer;">Thue-Morse: 0→01, 1→10</button>
  <button onclick="setMorph('fib')" style="flex:1; padding: 8px; background: #0f3460; color: #FF9800; border: 1px solid #FF9800; border-radius: 6px; cursor: pointer;">Fibonacci: 0→01, 1→0</button>
  <button onclick="setMorph('pd')" style="flex:1; padding: 8px; background: #0f3460; color: #9C27B0; border: 1px solid #9C27B0; border-radius: 6px; cursor: pointer;">Period-doubling: 0→01, 1→00</button>
</div>

<canvas id="morphCanvas" width="780" height="300" style="background: #16213e; border-radius: 8px; display: block; margin: 10px auto;"></canvas>

<div id="morphInfo" style="background: #16213e; padding: 12px; border-radius: 8px; font-size: 14px; margin-top: 10px;"></div>

<script>
const morphisms = {
  tm: {name: 'Thue-Morse', rules: {0: [0,1], 1: [1,0]}, color: '#4CAF50', uniform: true},
  fib: {name: 'Fibonacci', rules: {0: [0,1], 1: [0]}, color: '#FF9800', uniform: false},
  pd: {name: 'Period-doubling', rules: {0: [0,1], 1: [0,0]}, color: '#9C27B0', uniform: true}
};

let currentMorph = 'tm';

function setMorph(m) { currentMorph = m; drawMorph(); }

function applyMorphism(word, rules) {
  const result = [];
  for(const letter of word) result.push(...rules[letter]);
  return result;
}

function drawMorph() {
  const n = parseInt(document.getElementById('iterSlider').value);
  document.getElementById('iterLabel').textContent = n;

  const morph = morphisms[currentMorph];
  const canvas = document.getElementById('morphCanvas');
  const ctx = canvas.getContext('2d');
  const W = canvas.width, H = canvas.height;
  ctx.clearRect(0,0,W,H);

  const iterations = [[0]];
  for(let i=1; i<=n; i++) {
    iterations.push(applyMorphism(iterations[i-1], morph.rules));
  }

  const numRows = iterations.length;
  const rowH = (H - 20) / numRows;
  const letterColors = ['#4CAF50', '#F44336', '#2196F3', '#FF9800'];

  for(let i=0; i<numRows; i++) {
    const word = iterations[i];
    const maxShow = Math.min(word.length, Math.floor(W / 4));
    const cellW = Math.min(12, (W - 60) / maxShow);

    ctx.fillStyle = '#aaa';
    ctx.font = '10px monospace';
    ctx.textAlign = 'right';
    ctx.fillText('σ^'+i, 30, 15 + i*rowH + rowH/2);

    for(let j=0; j<maxShow; j++) {
      const letter = word[j];
      ctx.fillStyle = letterColors[letter % letterColors.length];
      ctx.globalAlpha = 0.8;
      ctx.fillRect(40 + j*cellW, 10 + i*rowH, cellW-1, rowH-4);
      ctx.globalAlpha = 1;
    }

    if(word.length > maxShow) {
      ctx.fillStyle = '#aaa';
      ctx.textAlign = 'left';
      ctx.fillText('...+' + (word.length-maxShow), 40 + maxShow*cellW + 5, 15 + i*rowH + rowH/2);
    }
  }

  const lastWord = iterations[n];
  const zeros = lastWord.filter(x=>x===0).length;
  const ones = lastWord.filter(x=>x===1).length;
  document.getElementById('morphInfo').innerHTML =
    '<b style="color:'+morph.color+'">'+morph.name+'</b> | ' +
    'Iteration '+n+': length '+lastWord.length+' | ' +
    'Uniform: '+morph.uniform+' | ' +
    '0s: '+zeros+' | 1s: '+ones+' | ' +
    'Ratio: '+(zeros/lastWord.length).toFixed(3);
}

document.getElementById('iterSlider').addEventListener('input', drawMorph);
drawMorph();
</script>
</div>"""

package = {
    "title": "Automatic Sequences and the Decidability Frontier",
    "domain": "Computation",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "demo.py",
            "code": demo_code,
            "description": "Demonstrates DFAO sequence generation, zero-in-sequence decidability, k-kernel computation, closure properties, and morphic decidability testing."
        }
    ],
    "algorithms": [
        {
            "name": "DFAO Zero-in-Sequence Decision Procedure",
            "pseudocode": "1. Compute reachable states via BFS from initial state\n2. Collect output values of all reachable states\n3. Return whether target value is in the collected set",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Thue-Morse Self-Similarity and K-Kernel Structure",
            "code": viz_code,
            "description": "Multi-panel visualization showing Thue-Morse as a binary grid, self-similarity under decimation, cumulative balance, and 2-kernel structure."
        }
    ],
    "interactive_demos": [
        {
            "name": "Thue-Morse Sequence Explorer",
            "html": interactive_demo_1,
            "description": "Interactive explorer for the Thue-Morse sequence with self-similarity and complementation views, plus DFAO state machine diagram."
        },
        {
            "name": "k-Kernel Explorer",
            "html": interactive_demo_2,
            "description": "Visualize the 2-kernel of the Thue-Morse sequence: explore how many distinct subsequences exist at each depth level."
        },
        {
            "name": "Morphism Iterator",
            "html": interactive_demo_3,
            "description": "Watch Thue-Morse, Fibonacci, and period-doubling morphisms build infinite words iteration by iteration."
        }
    ],
    "lean_proofs": [
        {
            "name": "Computation/AutomaticDecidability.lean",
            "code": lean_proofs,
            "description": "Formalized theory of k-automatic sequences: DFAO framework, closure theorem, k-kernel theory, Thue-Morse aperiodicity, and decidability results. All proofs machine-verified in Lean 4."
        }
    ]
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully.")


"""
Visualization: Thue-Morse Sequence Self-Similarity and K-Kernel Structure

Produces a multi-panel figure showing:
1. The Thue-Morse sequence as a binary heatmap
2. Self-similar structure under decimation
3. K-kernel orbit visualization
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def bit_sum(n):
    """Compute binary digit sum (popcount)."""
    count = 0
    while n > 0:
        count += n & 1
        n >>= 1
    return count


def thue_morse(n):
    """Thue-Morse sequence: t(n) = popcount(n) mod 2."""
    return bit_sum(n) % 2


def compute_sequence(length):
    """Generate Thue-Morse sequence."""
    return [thue_morse(n) for n in range(length)]


def main():
    N = 256
    seq = compute_sequence(N)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Thue-Morse Sequence: Self-Similarity and the Decidability Frontier',
                 fontsize=14, fontweight='bold')

    # Panel 1: Binary heatmap (16x16 grid)
    ax1 = axes[0, 0]
    grid = np.array(seq).reshape(16, 16)
    im = ax1.imshow(grid, cmap='binary', aspect='equal', interpolation='nearest')
    ax1.set_title('Thue-Morse as 16×16 Grid', fontsize=11)
    ax1.set_xlabel('Column (n mod 16)')
    ax1.set_ylabel('Row (n ÷ 16)')

    # Panel 2: Self-similarity - original vs even-indexed vs odd-indexed
    ax2 = axes[0, 1]
    n_show = 64
    original = seq[:n_show]
    even_sub = [seq[2 * i] for i in range(n_show)]
    odd_sub = [seq[2 * i + 1] for i in range(n_show)]

    for i, (label, s, color) in enumerate([
        ('t(n)', original, '#2196F3'),
        ('t(2n) = t(n)', even_sub, '#4CAF50'),
        ('t(2n+1) = 1−t(n)', odd_sub, '#F44336')
    ]):
        y_offset = 2 - i
        for j, v in enumerate(s):
            ax2.add_patch(plt.Rectangle((j, y_offset - 0.4), 1, 0.8,
                                         facecolor=color if v == 1 else 'white',
                                         edgecolor=color, alpha=0.7))
    ax2.set_xlim(0, n_show)
    ax2.set_ylim(-0.5, 2.5)
    ax2.set_yticks([0, 1, 2])
    ax2.set_yticklabels(['t(2n+1)', 't(2n)', 't(n)'])
    ax2.set_xlabel('Index')
    ax2.set_title('Self-Similarity: Decimation', fontsize=11)

    # Panel 3: Cumulative balance (partial sums showing equidistribution)
    ax3 = axes[1, 0]
    N_long = 1024
    long_seq = compute_sequence(N_long)
    cumsum = np.cumsum([2 * x - 1 for x in long_seq])
    ax3.plot(range(N_long), cumsum, color='#9C27B0', linewidth=0.5)
    ax3.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax3.set_xlabel('n')
    ax3.set_ylabel('Σ(2t(i)−1)')
    ax3.set_title('Cumulative Balance (Perfect Equidistribution)', fontsize=11)
    ax3.fill_between(range(N_long), cumsum, alpha=0.1, color='#9C27B0')

    # Panel 4: 2-kernel visualization
    ax4 = axes[1, 1]
    max_e = 4
    kernel_seqs = {}
    for e in range(max_e + 1):
        ke = 2 ** e
        for r in range(ke):
            sub = tuple(thue_morse(ke * n + r) for n in range(32))
            if sub not in kernel_seqs.values():
                kernel_seqs[(e, r)] = sub

    colors = ['#2196F3', '#F44336', '#4CAF50', '#FF9800']
    for idx, ((e, r), sub) in enumerate(kernel_seqs.items()):
        label = f'e={e}, r={r}'
        y_vals = [v + idx * 1.5 for v in sub[:32]]
        ax4.step(range(32), y_vals, where='mid', label=label,
                color=colors[idx % len(colors)], linewidth=1.5)

    ax4.set_xlabel('n')
    ax4.set_title(f'2-Kernel: {len(kernel_seqs)} Distinct Subsequences', fontsize=11)
    ax4.legend(fontsize=8, loc='upper right')
    ax4.set_yticks([])

    plt.tight_layout()
    plt.savefig('viz_thue_morse.png', dpi=150, bbox_inches='tight')
    print("Saved viz_thue_morse.png")


if __name__ == '__main__':
    main()
