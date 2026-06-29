import json, pathlib

root = pathlib.Path("/workspace/request-project")

def rd(name):
    return (root / name).read_text()

article = rd("ARTICLE.md")
paper = rd("RESEARCH_PAPER.md")
tex = rd("RESEARCH_PAPER.tex")
demo = rd("demo.py")
lean = rd("Catalog/6d018212_retry2_aristotle/Algebra/MDSUncertainty.lean")

# ---------------------------------------------------------------------------
demo1_code = r'''from fractions import Fraction
from itertools import combinations, product
from typing import List, Tuple

Scalar = object
Matrix = List[List[Scalar]]

def det_modp(M: Matrix, p: int) -> int:
    """Determinant of a square matrix over F_p by Gaussian elimination."""
    n = len(M); A = [[x % p for x in row] for row in M]; d = 1
    for col in range(n):
        pr = next((r for r in range(col, n) if A[r][col] % p != 0), None)
        if pr is None:
            return 0
        if pr != col:
            A[col], A[pr] = A[pr], A[col]; d = (-d) % p
        inv = pow(A[col][col], p - 2, p); d = (d * A[col][col]) % p
        for r in range(col + 1, n):
            f = (A[r][col] * inv) % p
            A[r] = [(a - f * b) % p for a, b in zip(A[r], A[col])]
    return d % p

def is_mds_modp(M: Matrix, p: int) -> bool:
    """True iff every square submatrix is invertible over F_p (Definition IsMDS)."""
    n = len(M)
    for k in range(1, n + 1):
        for rs in combinations(range(n), k):
            for cs in combinations(range(n), k):
                if det_modp([[M[r][c] for c in cs] for r in rs], p) == 0:
                    return False
    return True

def min_support_sum(M: Matrix, p: int) -> int:
    """Minimum of |supp(f)| + |supp(Mf)| over all nonzero f in F_p^n."""
    n = len(M); best = None
    for f in product(range(p), repeat=n):
        if not any(f):
            continue
        Mf = [sum(M[i][j] * f[j] for j in range(n)) % p for i in range(n)]
        s = sum(1 for v in f if v) + sum(1 for v in Mf if v % p)
        best = s if best is None else min(best, s)
    return best

def verify_equivalence(M: Matrix, p: int) -> Tuple[bool, int, int, bool]:
    """Return (is_mds, min_support_sum, n+1, equivalence_holds)."""
    n = len(M)
    mds = is_mds_modp(M, p)
    mss = min_support_sum(M, p)
    # mds  <=>  bound n+1 holds  <=>  min support sum == n+1
    return mds, mss, n + 1, (mds == (mss == n + 1))

if __name__ == "__main__":
    p = 7
    # Cauchy matrix C[i][j] = 1/(x_i - y_j) is guaranteed MDS.
    xs, ys = [0, 1, 2], [3, 4, 5]
    C = [[pow((x - y) % p, p - 2, p) for y in ys] for x in xs]
    print("Cauchy/MDS over F_7:", verify_equivalence(C, p))
    # A matrix with a repeated column-block is not MDS.
    N = [[1, 1, 0], [1, 1, 0], [0, 0, 1]]
    print("Non-MDS over F_7:   ", verify_equivalence(N, p))
'''

demo2_code = r'''from fractions import Fraction
from typing import List

Vector = List[Fraction]
Matrix = List[List[Fraction]]

def mat_vec(M: Matrix, f: Vector) -> Vector:
    return [sum(M[i][j] * f[j] for j in range(len(f))) for i in range(len(M))]

def support_sum(M: Matrix, f: Vector) -> int:
    Mf = mat_vec(M, f)
    return sum(1 for x in f if x != 0) + sum(1 for x in Mf if x != 0)

def spike(n: int, i: int) -> Vector:
    e = [Fraction(0)] * n
    e[i] = Fraction(1)
    return e

def demonstrate_sharpness(M: Matrix) -> None:
    """
    For an MDS matrix, the theorem mds_implies_uncertainty guarantees
    support_sum >= n+1 for every nonzero f, while singleton_bound shows that
    each spike input e_i achieves support_sum = 1 + |supp(column i)| <= n+1.
    For an MDS matrix every column is full, so each spike attains EXACTLY n+1.
    """
    n = len(M)
    print(f"n = {n}, target bound n+1 = {n+1}")
    for i in range(n):
        s = support_sum(M, spike(n, i))
        print(f"  spike e_{i}: support_sum = {s}  (singleton_bound: <= n+1)")
    # a dense input exceeds the bound
    dense = [Fraction(k + 1) for k in range(n)]
    print(f"  dense input {[int(x) for x in dense]}: support_sum ="
          f" {support_sum(M, dense)}  (>= n+1)")

if __name__ == "__main__":
    # 3x3 Vandermonde on nodes 1,2,3 over the rationals (MDS, Reed-Solomon).
    nodes = [1, 2, 3]
    V = [[Fraction(x) ** j for x in nodes] for j in range(3)]
    demonstrate_sharpness(V)
'''

algo1_code = r'''from itertools import combinations
from typing import List

Matrix = List[List[float]]

def submatrix_det_bareiss(M: Matrix) -> float:
    """Fraction-free Bareiss determinant (exact for integer/rational input)."""
    n = len(M); A = [row[:] for row in M]; prev = 1.0; sign = 1
    for k in range(n - 1):
        if A[k][k] == 0:
            swap = next((r for r in range(k + 1, n) if A[r][k] != 0), None)
            if swap is None:
                return 0.0
            A[k], A[swap] = A[swap], A[k]; sign = -sign
        for i in range(k + 1, n):
            for j in range(k + 1, n):
                A[i][j] = (A[i][j] * A[k][k] - A[i][k] * A[k][j]) / prev
        prev = A[k][k]
    return sign * A[n - 1][n - 1]

def is_mds(M: Matrix) -> bool:
    """
    Decide the Maximum Distance Separable property: every k x k submatrix,
    over all sizes k and all row/column subsets, has nonzero determinant.
    Complexity: sum_{k=1}^n C(n,k)^2 = C(2n,n) - 1 determinant evaluations,
    each O(k^3); exact and practical for the small matrices used in code design.
    """
    n = len(M)
    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                sub = [[M[r][c] for c in cols] for r in rows]
                if abs(submatrix_det_bareiss(sub)) < 1e-9:
                    return False
    return True
'''

algo2_code = r'''from fractions import Fraction
from itertools import combinations
from typing import List, Optional, Tuple

Matrix = List[List[Fraction]]
Vector = List[Fraction]

def det(M: Matrix) -> Fraction:
    n = len(M); A = [row[:] for row in M]; d = Fraction(1)
    for c in range(n):
        pr = next((r for r in range(c, n) if A[r][c] != 0), None)
        if pr is None:
            return Fraction(0)
        if pr != c:
            A[c], A[pr] = A[pr], A[c]; d = -d
        d *= A[c][c]
        for r in range(c + 1, n):
            f = A[r][c] / A[c][c]
            A[r] = [a - f * b for a, b in zip(A[r], A[c])]
    return d

def kernel_vector(A: Matrix) -> Optional[Vector]:
    """A nonzero kernel vector of a singular square matrix, via RREF."""
    k = len(A); M = [row[:] for row in A]; pivots: List[int] = []; row = 0
    for col in range(k):
        sel = next((r for r in range(row, k) if M[r][col] != 0), None)
        if sel is None:
            continue
        M[row], M[sel] = M[sel], M[row]
        pv = M[row][col]; M[row] = [x / pv for x in M[row]]
        for r in range(k):
            if r != row and M[r][col] != 0:
                fac = M[r][col]; M[r] = [a - fac * b for a, b in zip(M[r], M[row])]
        pivots.append(col); row += 1
    free = [c for c in range(k) if c not in pivots]
    if not free:
        return None
    x = [Fraction(0)] * k; x[free[0]] = Fraction(1)
    for r, pc in enumerate(pivots):
        x[pc] = -M[r][free[0]]
    return x

def extract_violator(M: Matrix) -> Optional[Vector]:
    """
    Given a NON-MDS matrix, produce a sparse vector f != 0 with
    |supp(f)| + |supp(Mf)| <= n  (constructive content of
    not_mds_implies_violator).  Steps: find a singular square submatrix,
    take a kernel vector of it, and pad with zeros along the chosen columns.
    """
    n = len(M)
    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                sub = [[M[r][c] for c in cols] for r in rows]
                if det(sub) == 0:
                    v = kernel_vector(sub)
                    if v is None:
                        continue
                    f = [Fraction(0)] * n
                    for idx, c in enumerate(cols):
                        f[c] = v[idx]
                    return f
    return None
'''

viz_code = r'''"""
Visualization: support-sum landscapes for MDS vs non-MDS 3x3 matrices over F_5.

For each nonzero f in F_5^3 we plot |supp(f)| + |supp(Mf)|.  For an MDS matrix
the histogram is entirely >= n+1 = 4 with mass exactly at 4 (the sharp floor);
for a non-MDS matrix some f fall below 4, exposing the uncertainty violators.
"""
from itertools import product
from typing import List
import matplotlib.pyplot as plt

p, n = 5, 3

def support_sums(M: List[List[int]]) -> List[int]:
    out = []
    for f in product(range(p), repeat=n):
        if not any(f):
            continue
        Mf = [sum(M[i][j] * f[j] for j in range(n)) % p for i in range(n)]
        out.append(sum(1 for v in f if v) + sum(1 for v in Mf if v))
    return out

# MDS Cauchy matrix over F_5 and a deliberately non-MDS matrix.
xs, ys = [0, 1, 2], [2, 3, 4]
mds = [[pow((x - y) % p, p - 2, p) for y in ys] for x in xs]
non_mds = [[1, 1, 0], [2, 2, 0], [0, 0, 1]]

fig, axes = plt.subplots(1, 2, figsize=(11, 4), sharey=True)
for ax, M, title in [(axes[0], mds, "MDS (Cauchy)"),
                     (axes[1], non_mds, "Non-MDS")]:
    sums = support_sums(M)
    bins = range(min(sums), max(sums) + 2)
    ax.hist(sums, bins=bins, align="left", rwidth=0.85, color="#3b7dd8")
    ax.axvline(n + 1 - 0.5, color="crimson", linestyle="--",
               label=f"forbidden line < n+1 = {n+1}")
    ax.set_title(f"{title}: support-sum distribution")
    ax.set_xlabel("|supp(f)| + |supp(Mf)|")
    ax.legend()
axes[0].set_ylabel("number of nonzero f")
fig.suptitle("MDS forbids support sums below n+1; non-MDS does not")
fig.tight_layout()
fig.savefig("mds_uncertainty_landscape.png", dpi=150)
print("saved mds_uncertainty_landscape.png")
'''

interactive_html = r'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<title>MDS &amp; the Uncertainty Principle &mdash; Interactive Explorer</title>
<style>
  body{font-family:Georgia,serif;max-width:760px;margin:2rem auto;padding:0 1rem;color:#1c2330;background:#f7f9fc}
  h1{font-size:1.5rem}
  .grid{display:grid;gap:6px;margin:1rem 0}
  input.cell{width:54px;text-align:center;font-size:1rem;padding:6px;border:1px solid #b9c4d6;border-radius:6px}
  button{font-size:1rem;padding:8px 16px;border:0;border-radius:8px;background:#3b7dd8;color:#fff;cursor:pointer}
  button.alt{background:#6b7280}
  .card{background:#fff;border:1px solid #dce3ee;border-radius:12px;padding:1rem 1.2rem;margin-top:1rem}
  .ok{color:#15803d;font-weight:bold}.bad{color:#b91c1c;font-weight:bold}
  code{background:#eef2f8;padding:1px 5px;border-radius:4px}
  .muted{color:#5b6678;font-size:.92rem}
</style>
</head>
<body>
<h1>Can you hide a signal in both places at once?</h1>
<p class="muted">Enter an integer matrix <code>M</code>. We test whether it is
<b>MDS</b> (every square submatrix has nonzero determinant) and whether it obeys
the sharp uncertainty bound <code>|supp(f)| + |supp(Mf)| &ge; n+1</code> for every
nonzero integer vector with entries in a chosen range. The theorem says these two
properties are <i>equivalent</i>.</p>

<label>Size n: <select id="n" onchange="buildGrid()">
  <option>2</option><option selected>3</option><option>4</option></select></label>
&nbsp;&nbsp;<label>scan range &plusmn;<input id="rng" class="cell" value="2" style="width:40px"></label>
<div id="grid" class="grid"></div>
<button onclick="run()">Analyze matrix</button>
<button class="alt" onclick="loadMDS()">Load MDS example</button>
<button class="alt" onclick="loadBad()">Load non-MDS example</button>

<div id="out"></div>

<script>
function buildGrid(){
  const n=+document.getElementById('n').value;
  const g=document.getElementById('grid');
  g.style.gridTemplateColumns=`repeat(${n},auto)`;
  g.innerHTML='';
  for(let i=0;i<n;i++)for(let j=0;j<n;j++){
    const inp=document.createElement('input');
    inp.className='cell';inp.id=`c_${i}_${j}`;inp.value=(i===j)?1:0;
    g.appendChild(inp);
  }
}
function getM(){
  const n=+document.getElementById('n').value;const M=[];
  for(let i=0;i<n;i++){const r=[];for(let j=0;j<n;j++)
    r.push(parseInt(document.getElementById(`c_${i}_${j}`).value||'0',10));M.push(r);}
  return M;
}
function setM(M){
  document.getElementById('n').value=M.length;buildGrid();
  for(let i=0;i<M.length;i++)for(let j=0;j<M.length;j++)
    document.getElementById(`c_${i}_${j}`).value=M[i][j];
}
function loadMDS(){setM([[1,1,1],[1,2,4],[1,3,9]]);}      // Vandermonde
function loadBad(){setM([[1,1,0],[1,1,0],[0,0,1]]);}      // repeated block
// exact integer determinant via Bareiss
function detI(A){
  const n=A.length;A=A.map(r=>r.slice());let prev=1,sign=1;
  for(let k=0;k<n-1;k++){
    if(A[k][k]===0){let s=-1;for(let r=k+1;r<n;r++)if(A[r][k]!==0){s=r;break;}
      if(s<0)return 0;[A[k],A[s]]=[A[s],A[k]];sign=-sign;}
    for(let i=k+1;i<n;i++)for(let j=k+1;j<n;j++)
      A[i][j]=(A[i][j]*A[k][k]-A[i][k]*A[k][j])/prev;
    prev=A[k][k];
  }
  return sign*A[n-1][n-1];
}
function combos(n,k){const res=[],c=[];(function go(s){if(c.length===k){res.push(c.slice());return;}
  for(let i=s;i<n;i++){c.push(i);go(i+1);c.pop();}})(0);return res;}
function isMDS(M){const n=M.length;
  for(let k=1;k<=n;k++)for(const rs of combos(n,k))for(const cs of combos(n,k)){
    const sub=rs.map(r=>cs.map(c=>M[r][c]));
    if(Math.abs(detI(sub))<1e-9)return false;}
  return true;}
function run(){
  const M=getM(),n=M.length,R=+document.getElementById('rng').value;
  const mds=isMDS(M);
  // scan vectors f in [-R,R]^n, find min support sum and a violator if any
  let best=Infinity,worst=null;const idx=new Array(n).fill(-R);
  function supp(v){return v.reduce((a,x)=>a+(x!==0?1:0),0);}
  const total=Math.pow(2*R+1,n);
  for(let t=0;t<total;t++){
    let x=t,f=[];for(let i=0;i<n;i++){f.push((x%(2*R+1))-R);x=Math.floor(x/(2*R+1));}
    if(f.every(v=>v===0))continue;
    const Mf=M.map(row=>row.reduce((a,m,j)=>a+m*f[j],0));
    const s=supp(f)+supp(Mf);
    if(s<best){best=s;worst=[f.slice(),Mf.slice(),s];}
  }
  const bound=n+1, holds=best>=bound;
  let html=`<div class="card"><b>n = ${n}</b>, target bound n+1 = ${bound}<br>`;
  html+=`MDS (every square submatrix invertible): `+
        (mds?'<span class="ok">YES</span>':'<span class="bad">NO</span>')+'<br>';
  html+=`Smallest support sum found over the scanned range: <b>${best}</b><br>`;
  html+=`Uncertainty bound &ge; n+1 holds on scan: `+
        (holds?'<span class="ok">YES</span>':'<span class="bad">NO</span>')+'<br>';
  const agree=(mds===holds);
  html+=`<br><b>Theorem check:</b> MDS &hArr; bound &mdash; `+
        (agree?'<span class="ok">consistent &#10003;</span>'
              :'<span class="bad">widen the scan range</span>')+'</div>';
  if(!holds&&worst){
    html+=`<div class="card"><b>Uncertainty violator found</b> (proof that M is not MDS):<br>`+
          `f = [${worst[0]}], &nbsp; Mf = [${worst[1]}], &nbsp; support sum = ${worst[2]} `+
          `&le; n = ${n}.</div>`;
  } else if(mds){
    html+=`<div class="card">No violator exists: every nonzero input keeps the total `+
          `aliveness at &ge; ${bound}. The spike inputs attain exactly ${bound}, `+
          `so the bound is <i>sharp</i>.</div>`;
  }
  document.getElementById('out').innerHTML=html;
}
buildGrid();
</script>
</body>
</html>
'''

future_directions = r'''# Future directions — the MDS–Uncertainty equivalence

Derived from this cycle's results: the exact characterization
`mds_iff_uncertainty` (MDS ⇔ every nonzero f has support sum ≥ n+1), its
optimality `singleton_bound`, and the transpose-closure `mds_transpose`.

## Direction 1 (Quantitative defect theory)
The `UncertaintyProfile` structure records a *certified* support-sum lower bound
`certifiedBound`. For a non-MDS matrix the largest valid bound b < n+1 is an
**uncertainty defect** measuring how far M is from MDS.
- The key insight is that `not_mds_implies_violator` already produces, from the
  smallest singular minor, a vector with support sum ≤ n; tracking the *size* of
  that minor should pin down the exact defect.
- Why now? The two-sided argument of `mds_iff_uncertainty` isolates exactly the
  minor whose singularity controls the bound, so the defect is a single combinatorial
  quantity to optimize.

## Direction 2 (Structured MDS families)
Give determinantal criteria for when circulant, Cauchy, and Hankel matrices are
MDS, feeding directly into `mds_iff_uncertainty`.
- The key insight is that Cauchy matrices are MDS because every square submatrix is
  again Cauchy; analogous closure properties for other structured families would
  yield large explicit MDS catalogs for lightweight diffusion layers.
- Why now? `mds_invertible` and the submatrix lemma `submatrix_mulVec_of_support`
  are stated generically, so only the determinant evaluation specializes per family.

## Direction 3 (Rectangular / over-complete generalization)
Extend the equivalence to m×n generator matrices (m < n), where MDS means every
m×m submatrix is invertible, aligning with the full Singleton bound for [n,k] codes
and with compressed-sensing measurement matrices.
- The key insight is that the forward proof `mds_implies_uncertainty` only uses a
  square submatrix carved from the support of f and the zero rows of Mf; the same
  carving works when the ambient map is rectangular.
- Why now? The counting identity `vecSupport_card_add_vecZeros_card` and the
  restriction lemma already make no use of squareness beyond the final determinant
  step.

## Direction 4 (Finite-field harmonic analysis)
Use `mds_iff_uncertainty` to transfer sharp uncertainty results between Fourier-type
MDS transforms (the DFT over 𝔽_p is MDS by Chebotarev's theorem) and combinatorial
coding bounds, including approximate-support (stability) versions.
- The key insight is that the DFT matrix being MDS instantly yields the finite
  Donoho–Stark/Tao bound p+1 as a special case of `mds_implies_uncertainty`.
- Why now? The equivalence is field-agnostic, so prime-field Fourier analysis and
  Reed–Solomon coding become two readings of the same theorem.
'''

pkg = {
  "title": "The MDS–Uncertainty Equivalence: a Sharp Additive Uncertainty Principle for Maximum Distance Separable Matrices",
  "domain": "Algebra",
  "description": "An n×n matrix over a field is Maximum Distance Separable (every square submatrix invertible) if and only if every nonzero vector f satisfies |supp(f)| + |supp(Mf)| ≥ n+1, a bound shown to be optimal for any invertible matrix.",
  "authors": ["Aristotle"],
  "date": "2026-06-20",
  "key_results": [
    "mds_iff_uncertainty: IsMDS M ↔ SatisfiesUncertainty M (n+1)",
    "mds_implies_uncertainty: MDS matrices force |supp(f)| + |supp(Mf)| ≥ n+1 for all nonzero f",
    "not_mds_implies_violator: a non-MDS matrix admits a nonzero f with support sum ≤ n",
    "singleton_bound: every invertible matrix admits a nonzero f with support sum ≤ n+1 (optimality)",
    "mds_transpose: the MDS property is closed under transpose"
  ],
  "keywords": [
    "MDS matrix", "uncertainty principle", "vecSupport", "submatrix determinant",
    "Reed-Solomon codes", "Singleton bound", "support", "Donoho-Stark"
  ],
  "article": article,
  "research_paper": paper,
  "research_paper_tex": tex,
  "demo": demo,
  "demos": [
    {
      "name": "Exhaustive MDS–Uncertainty Equivalence Verification over a Prime Field",
      "description": "Directly exercises the main theorem mds_iff_uncertainty by, for a given matrix over F_p, (i) testing the MDS property through every square submatrix determinant and (ii) computing the exact minimum of |supp(f)|+|supp(Mf)| over all nonzero f in F_p^n. It confirms that the matrix is MDS precisely when that minimum equals n+1, demonstrating both directions of the equivalence and the sharpness of the bound on a guaranteed-MDS Cauchy matrix and on a non-MDS matrix.",
      "code": demo1_code
    },
    {
      "name": "Sharpness of the n+1 Support-Sum Bound via Singleton Spike Inputs",
      "description": "Demonstrates singleton_bound and the optimality corollary on a 3×3 Vandermonde (Reed–Solomon) matrix over the rationals: each standard basis spike e_i attains support sum exactly n+1 because every column of an MDS matrix is full, while dense inputs strictly exceed the bound. This shows the floor of n+1 in mds_implies_uncertainty is achieved and cannot be raised for any invertible matrix.",
      "code": demo2_code
    }
  ],
  "algorithms": [
    {
      "name": "Exhaustive Maximum-Distance-Separability Decision via Submatrix Determinants",
      "description": "Decides the IsMDS property by evaluating the determinant of every k×k submatrix for all sizes k and all choices of k rows and k columns, using fraction-free Bareiss elimination for exactness. The matrix is MDS iff all such determinants are nonzero. There are C(2n,n)−1 submatrices and each determinant costs O(k^3), so the procedure is exponential in n but exact and entirely practical for the small matrices used in code and cipher design; it underlies the forward verification of mds_iff_uncertainty.",
      "pseudocode": "function IS_MDS(M, n):\n  for k = 1 to n:\n    for each k-subset R of {0,...,n-1} (rows):\n      for each k-subset C of {0,...,n-1} (columns):\n        S <- submatrix of M on rows R, columns C\n        if det(S) == 0:\n          return false        # found a singular minor\n  return true                  # every square submatrix invertible",
      "code": algo1_code
    },
    {
      "name": "Sparse Uncertainty-Violator Extraction from a Singular Submatrix Kernel",
      "description": "Implements the constructive content of not_mds_implies_violator. Given a non-MDS matrix, it locates the first singular square submatrix M|_{r,c}, computes a nonzero kernel vector v of it via reduced row echelon form, and lifts v to a full-length vector f by placing its entries on the chosen columns and zeros elsewhere. The resulting f satisfies |supp(f)|+|supp(Mf)| ≤ n, certifying the failure of the uncertainty bound by an explicit sparse counterexample. Complexity is dominated by the submatrix search, O(C(2n,n)·n^3).",
      "pseudocode": "function EXTRACT_VIOLATOR(M, n):\n  for k = 1 to n:\n    for each k-subset R of rows:\n      for each k-subset C of columns:\n        S <- submatrix(M, R, C)\n        if det(S) == 0:\n          v <- nonzero kernel vector of S      # via RREF, free column = 1\n          if v exists:\n            f <- zero vector of length n\n            for idx, c in enumerate(C): f[c] <- v[idx]\n            return f                            # |supp f|+|supp Mf| <= n\n  return NONE                                   # M was MDS",
      "code": algo2_code
    }
  ],
  "visualizations": [
    {
      "name": "Support-Sum Distribution Landscapes for MDS versus Non-MDS Matrices",
      "description": "Side-by-side histograms of |supp(f)|+|supp(Mf)| over all nonzero f in F_5^3 for an MDS Cauchy matrix and a non-MDS matrix. The MDS histogram lies entirely at or above n+1=4 with mass at the sharp floor, while the non-MDS histogram spills below the red 'forbidden' line, visually exposing the uncertainty violators guaranteed by not_mds_implies_violator.",
      "code": viz_code
    }
  ],
  "interactive_demos": [
    {
      "title": "Can You Hide a Signal in Both Places at Once? — Live MDS & Uncertainty Explorer",
      "description": "A self-contained HTML/JavaScript widget in which a reader enters a small integer matrix, then sees whether it is MDS (via exact Bareiss determinants of every square submatrix) and whether the sharp uncertainty bound |supp(f)|+|supp(Mf)| ≥ n+1 holds across a scanned vector range. It reports the smallest support sum found, flags any explicit uncertainty violator, and confirms the equivalence mds_iff_uncertainty in real time, with one-click MDS (Vandermonde) and non-MDS examples.",
      "html": interactive_html
    }
  ],
  "lean_proofs": lean,
  "future_directions": future_directions,
  "modules": {"demo": demo},
  "lean_files": ["Catalog/6d018212_retry2_aristotle/Algebra/MDSUncertainty.lean"]
}

(root / "PACKAGE.json").write_text(json.dumps(pkg, ensure_ascii=False, indent=2))
print("PACKAGE.json written:", (root / "PACKAGE.json").stat().st_size, "bytes")
# sanity: round-trip parse
json.loads((root / "PACKAGE.json").read_text())
print("JSON valid")
print("keys:", list(pkg.keys()))


"""
Numerical demonstrations of the MDS--Uncertainty equivalence.

Main theorem (mds_iff_uncertainty):
    An n x n matrix M over a field is Maximum Distance Separable (MDS) --
    every square submatrix has nonzero determinant -- if and only if for every
    nonzero vector f,
        |supp(f)| + |supp(M f)| >= n + 1,
    where supp(v) is the set of indices where v is nonzero.

The bound n+1 is optimal (singleton_bound): every invertible matrix admits a
nonzero f with |supp(f)| + |supp(M f)| <= n + 1.

This file is fully self-contained. It works exactly over the rationals
(via fractions.Fraction) and over prime finite fields F_p.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations, product
from typing import Callable, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# Generic field-element arithmetic helpers
# ----------------------------------------------------------------------------

Scalar = object  # Fraction for Q; int (mod p) for F_p
Matrix = List[List[Scalar]]
Vector = List[Scalar]


def mat_vec(M: Matrix, f: Vector, mul, add, zero) -> Vector:
    """Compute M f over a generic field given mul/add/zero operations."""
    n_rows = len(M)
    n_cols = len(M[0])
    out: Vector = []
    for i in range(n_rows):
        acc = zero
        for j in range(n_cols):
            acc = add(acc, mul(M[i][j], f[j]))
        out.append(acc)
    return out


def support(v: Vector, zero) -> List[int]:
    """Indices where v is nonzero (the support, as in vecSupport)."""
    return [i for i, x in enumerate(v) if x != zero]


def support_size(v: Vector, zero) -> int:
    return len(support(v, zero))


def submatrix(M: Matrix, rows: Sequence[int], cols: Sequence[int]) -> Matrix:
    """The submatrix selecting the given rows and columns."""
    return [[M[r][c] for c in cols] for r in rows]


def det(M: Matrix, mul, add, sub, div, zero, one) -> Scalar:
    """Determinant by fraction-free-safe Gaussian elimination over a field."""
    n = len(M)
    A = [row[:] for row in M]
    sign = one
    determinant = one
    for col in range(n):
        # find a pivot
        pivot_row = None
        for r in range(col, n):
            if A[r][col] != zero:
                pivot_row = r
                break
        if pivot_row is None:
            return zero
        if pivot_row != col:
            A[col], A[pivot_row] = A[pivot_row], A[col]
            sign = sub(zero, sign)  # negate
        pivot = A[col][col]
        determinant = mul(determinant, pivot)
        for r in range(col + 1, n):
            factor = div(A[r][col], pivot)
            for c in range(col, n):
                A[r][c] = sub(A[r][c], mul(factor, A[col][c]))
    return mul(sign, determinant)


# ----------------------------------------------------------------------------
# MDS test and uncertainty machinery (field-agnostic)
# ----------------------------------------------------------------------------

def is_mds(M: Matrix, mul, add, sub, div, zero, one) -> bool:
    """
    True iff EVERY square submatrix (all sizes k, all row/column choices) has
    nonzero determinant. This is Definition IsMDS.
    """
    n = len(M)
    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                if det(submatrix(M, rows, cols), mul, add, sub, div, zero, one) == zero:
                    return False
    return True


def first_singular_submatrix(
    M: Matrix, mul, add, sub, div, zero, one
) -> Optional[Tuple[Tuple[int, ...], Tuple[int, ...]]]:
    """Return (rows, cols) of the first singular square submatrix, or None."""
    n = len(M)
    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                if det(submatrix(M, rows, cols), mul, add, sub, div, zero, one) == zero:
                    return rows, cols
    return None


# ----------------------------------------------------------------------------
# Field instances
# ----------------------------------------------------------------------------

def rational_ops():
    return dict(
        mul=lambda a, b: a * b,
        add=lambda a, b: a + b,
        sub=lambda a, b: a - b,
        div=lambda a, b: a / b,
        zero=Fraction(0),
        one=Fraction(1),
    )


def prime_field_ops(p: int):
    return dict(
        mul=lambda a, b: (a * b) % p,
        add=lambda a, b: (a + b) % p,
        sub=lambda a, b: (a - b) % p,
        div=lambda a, b: (a * pow(b, p - 2, p)) % p,  # Fermat inverse
        zero=0,
        one=1 % p,
    )


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def verify_bound_over_prime_field(M: Matrix, p: int) -> Tuple[bool, int, int]:
    """
    Exhaustively check the MDS--Uncertainty equivalence over F_p:
    returns (matrix_is_mds, min_support_sum_over_nonzero_f, n+1).
    If MDS, min_support_sum should equal n+1 (sharpness).
    """
    ops = prime_field_ops(p)
    zero = ops["zero"]
    n = len(M)
    mds = is_mds(M, ops["mul"], ops["add"], ops["sub"], ops["div"], zero, ops["one"])
    min_sum = None
    for f in product(range(p), repeat=n):
        f = list(f)
        if all(x == zero for x in f):
            continue
        Mf = mat_vec(M, f, ops["mul"], ops["add"], zero)
        s = support_size(f, zero) + support_size(Mf, zero)
        min_sum = s if min_sum is None else min(min_sum, s)
    return mds, min_sum, n + 1


def find_rational_violator(M: Matrix) -> Optional[Vector]:
    """
    For a non-MDS rational matrix, build a sparse violator f (support sum <= n)
    by lifting a kernel vector of a singular submatrix (Theorem
    not_mds_implies_violator).
    """
    ops = rational_ops()
    sing = first_singular_submatrix(
        M, ops["mul"], ops["add"], ops["sub"], ops["div"], ops["zero"], ops["one"]
    )
    if sing is None:
        return None
    rows, cols = sing
    sub = submatrix(M, rows, cols)
    v = kernel_vector_rational(sub)
    if v is None:
        return None
    n = len(M)
    f = [Fraction(0)] * n
    for idx, c in enumerate(cols):
        f[c] = v[idx]
    return f


def kernel_vector_rational(A: Matrix) -> Optional[Vector]:
    """A nonzero rational kernel vector of a (singular) square matrix, or None."""
    k = len(A)
    M = [[Fraction(x) for x in row] for row in A]
    where_pivot: List[int] = []
    row = 0
    pivot_cols: List[int] = []
    for col in range(k):
        sel = None
        for r in range(row, k):
            if M[r][col] != 0:
                sel = r
                break
        if sel is None:
            continue
        M[row], M[sel] = M[sel], M[row]
        pv = M[row][col]
        M[row] = [x / pv for x in M[row]]
        for r in range(k):
            if r != row and M[r][col] != 0:
                fac = M[r][col]
                M[r] = [a - fac * b for a, b in zip(M[r], M[row])]
        pivot_cols.append(col)
        row += 1
    free_cols = [c for c in range(k) if c not in pivot_cols]
    if not free_cols:
        return None
    free = free_cols[0]
    x = [Fraction(0)] * k
    x[free] = Fraction(1)
    for r, pc in enumerate(pivot_cols):
        x[pc] = -M[r][free]
    return x


def main() -> None:
    print("=" * 72)
    print("MDS--Uncertainty equivalence: numerical demonstrations")
    print("=" * 72)

    Q = rational_ops()

    # ---- Example 1: 2x2 Hadamard matrix over Q (MDS) -------------------
    print("\n[1] 2x2 Hadamard M = [[1,1],[1,-1]] over the rationals")
    H = [[Fraction(1), Fraction(1)], [Fraction(1), Fraction(-1)]]
    mds = is_mds(H, Q["mul"], Q["add"], Q["sub"], Q["div"], Q["zero"], Q["one"])
    print(f"    is_mds(H) = {mds}  (expected True)")
    for f in ([1, 0], [0, 1], [1, 1], [1, 2]):
        fv = [Fraction(x) for x in f]
        Mf = mat_vec(H, fv, Q["mul"], Q["add"], Q["zero"])
        s = support_size(fv, Q["zero"]) + support_size(Mf, Q["zero"])
        print(f"    f={f!s:8} Mf={[int(x) for x in Mf]!s:10} support_sum={s} (>= n+1=3)")

    # ---- Example 2: non-MDS 2x2, find a violator -----------------------
    print("\n[2] Non-MDS M = [[1,1],[1,1]] over the rationals")
    S = [[Fraction(1), Fraction(1)], [Fraction(1), Fraction(1)]]
    mds = is_mds(S, Q["mul"], Q["add"], Q["sub"], Q["div"], Q["zero"], Q["one"])
    print(f"    is_mds(S) = {mds}  (expected False)")
    viol = find_rational_violator(S)
    Mf = mat_vec(S, viol, Q["mul"], Q["add"], Q["zero"])
    s = support_size(viol, Q["zero"]) + support_size(Mf, Q["zero"])
    print(f"    violator f={[int(x) for x in viol]} -> Mf={[int(x) for x in Mf]},"
          f" support_sum={s} (<= n=2, breaks the n+1 bound)")

    # ---- Example 3: 3x3 Vandermonde over Q (MDS, Reed-Solomon) ---------
    print("\n[3] 3x3 Vandermonde on nodes 1,2,3 over the rationals (Reed-Solomon)")
    nodes = [1, 2, 3]
    V = [[Fraction(x) ** j for x in nodes] for j in range(3)]
    mds = is_mds(V, Q["mul"], Q["add"], Q["sub"], Q["div"], Q["zero"], Q["one"])
    print(f"    is_mds(V) = {mds}  (expected True)")
    # spike inputs attain the n+1 = 4 bound; a generic input exceeds it.
    for f in ([1, 0, 0], [1, 1, 0], [1, 2, 3]):
        fv = [Fraction(x) for x in f]
        Mf = mat_vec(V, fv, Q["mul"], Q["add"], Q["zero"])
        s = support_size(fv, Q["zero"]) + support_size(Mf, Q["zero"])
        print(f"    f={f!s:10} support_sum={s} (>= n+1=4)")

    # ---- Example 4: exhaustive verification over F_7 -------------------
    print("\n[4] Exhaustive check over F_7 of the equivalence + sharpness")
    p = 7
    # Cauchy matrix C[i][j] = 1/(x_i - y_j) is ALWAYS MDS (every square
    # submatrix is again a Cauchy matrix, hence nonsingular).
    xs, ys = [0, 1, 2], [3, 4, 5]
    Cp = [[pow((x - y) % p, p - 2, p) for y in ys] for x in xs]
    mds, min_sum, target = verify_bound_over_prime_field(Cp, p)
    print(f"    Cauchy matrix over F_7 = {Cp}")
    print(f"    is_mds={mds}, min support_sum over nonzero f = {min_sum}, n+1 = {target}")
    print(f"    MDS <=> (min support_sum == n+1)? "
          f"{mds and min_sum == target}  (equivalence + sharpness confirmed)")

    # a non-MDS matrix over F_7
    Np = [[1, 1, 0], [1, 1, 0], [0, 0, 1]]
    mds2, min_sum2, target2 = verify_bound_over_prime_field(Np, p)
    print(f"    Singular-block matrix over F_7: is_mds={mds2}, "
          f"min support_sum = {min_sum2}, n+1 = {target2}")
    print(f"    MDS <=> (min support_sum == n+1)? "
          f"{mds2 == (min_sum2 == target2)}  (equivalence confirmed)")

    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
