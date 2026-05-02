## Research Task: Compositional tropical certified robustness for DAG ReLU networks with multiple residual and concatenation skip paths

Research Mode: PROVE

Develop a graph-theoretic extension of the existing residual-network robustness theory from sequential skip architectures to arbitrary finite feed-forward DAGs. The core goal is to formalize a dynamic-programming Lipschitz certificate on the computation graph and derive from it a multiclass `L∞` robustness radius. The interesting point is not merely that DAG networks are Lipschitz, but that the certificate is *compositional along branching and merging structure*, and that the resulting global constant is computable nodewise and specializes to the previously verified chain/residual bounds when the DAG is a path.

### Precise theorem targets

Use a finite index type for nodes and a topological order as the induction skeleton. A good concrete setup is:

```lean
open scoped BigOperators
open Finset

variable {V : Type} [Fintype V] [DecidableEq V]

/-- A topological ranking: every edge goes from smaller rank to larger rank. -/
variable (rank : V → ℕ)
variable (parents : V → Finset V)
variable (hparent : ∀ v u, u ∈ parents v → rank u < rank v)
```

Represent node semantics abstractly as functions `ℝ^d → ℝ^m` for varying output spaces, or, if dependent output dimensions become too heavy, first prove a scalar-valued version where every node computes a real-valued function. That scalar version already captures the key branching/merging argument and is enough to formalize the multiclass gap theorem by applying it to each logit difference.

A workable first theorem family is:

```lean
def LinfDist {n : ℕ} (x z : Fin n → ℝ) : ℝ := ‖x - z‖∞

def IsLipschitzWithLinf {n : ℕ} (K : ℝ) (f : (Fin n → ℝ) → ℝ) : Prop :=
  0 ≤ K ∧ ∀ x z, |f x - f z| ≤ K * ‖x - z‖∞
```

Then define a nodewise budget:

```lean
inductive NodeKind (V : Type)
| input
| affine    (A : ℝ) (b : ℝ)      -- scalar first pass
| relu
| skip1
| addMerge
| concatProxy                      -- optional abstraction for branch collection
```

and a semantics assignment

```lean
variable {n : ℕ}
variable (F : V → ((Fin n → ℝ) → ℝ))
variable (K : V → ℝ)
variable (kind : V → NodeKind V)
```

The key compositional theorem should be stated in a form like:

```lean
theorem node_lipschitz_of_topological_dp
  (hinput : ∀ v, kind v = NodeKind.input → IsLipschitzWithLinf 1 (F v))
  (haffine :
    ∀ v a b u,
      kind v = NodeKind.affine a b →
      u ∈ parents v →
      F v = fun x => a * F u x + b →
      K v ≤ |a| * K u)
  (hrelu :
    ∀ v u,
      kind v = NodeKind.relu →
      u ∈ parents v →
      F v = fun x => max (F u x) 0 →
      K v ≤ K u)
  (hskip1 :
    ∀ v u,
      kind v = NodeKind.skip1 →
      u ∈ parents v →
      K v ≤ K u)
  (hadd :
    ∀ v,
      kind v = NodeKind.addMerge →
      F v = fun x => ∑ u in parents v, F u x →
      K v ≤ ∑ u in parents v, K u)
  (hKnonneg : ∀ v, 0 ≤ K v)
  :
  ∀ v, IsLipschitzWithLinf (K v) (F v)
```

This is the central graph-induction result: every node inherits a certified `L∞` Lipschitz constant from its parents according to a dynamic program on the DAG.

Once this scalar theorem is established, lift it to multiclass outputs `f : (Fin n → ℝ) → Fin c → ℝ` by defining the logit difference

```lean
def logitGap {n c : ℕ} (f : (Fin n → ℝ) → Fin c → ℝ) (y j : Fin c) :
    (Fin n → ℝ) → ℝ :=
  fun x => f x y - f x j
```

and proving:

```lean
theorem logitGap_lipschitz_of_coordinate_lipschitz
  {n c : ℕ} {f : (Fin n → ℝ) → Fin c → ℝ} {Ky Kj : ℝ} {y j : Fin c}
  (hy : IsLipschitzWithLinf Ky (fun x => f x y))
  (hj : IsLipschitzWithLinf Kj (fun x => f x j)) :
  IsLipschitzWithLinf (Ky + Kj) (logitGap f y j)
```

In the common uniform-budget case this simplifies to `2 * K_DAG`. The robustness theorem should then be stated as:

```lean
def multiclassMargin {n c : ℕ} (f : (Fin n → ℝ) → Fin c → ℝ) (y : Fin c) (x : Fin n → ℝ) : ℝ :=
  infᵢ (fun j : {j : Fin c // j ≠ y} => f x y - f x j)

theorem certified_radius_linf
  {n c : ℕ} {f : (Fin n → ℝ) → Fin c → ℝ} {K : ℝ} {y : Fin c} {x z : Fin n → ℝ}
  (hK : 0 ≤ K)
  (hgap :
    ∀ j, j ≠ y → IsLipschitzWithLinf (2 * K) (fun w => f w y - f w j))
  (hmargin : 0 < multiclassMargin f y x)
  (hz : ‖z - x‖∞ < multiclassMargin f y x / (2 * K)) :
  ∀ j, j ≠ y → f z y > f z j
```

If the `sInf`/subtype formulation for `multiclassMargin` becomes awkward, use a finite `Finset` minimum:

```lean
def marginFinset {c : ℕ} (f : (Fin n → ℝ) → Fin c → ℝ) (y : Fin c) (x : Fin n → ℝ) : ℝ :=
  ((Finset.univ.erase y).inf' (by simpa using Finset.card_pos.mpr (Fin.pos_iff_ne_zero.mp ...))
    (fun j => f x y - f x j))
```

and prove the certificate with that concrete finite minimum.

### Concatenation theorem target

For concatenation, it is best to avoid dependent tensor bookkeeping at first and instead prove a norm inequality for product outputs. Model concatenation as pairing two branches:

```lean
def IsLipschitzWithLinfProd {n m₁ m₂ : ℕ}
    (K : ℝ) (f : (Fin n → ℝ) → (Fin m₁ → ℝ) × (Fin m₂ → ℝ)) : Prop :=
  0 ≤ K ∧ ∀ x z, ‖f x - f z‖∞ ≤ K * ‖x - z‖∞
```

Then prove one of the two norm-compatible aggregation lemmas:

```lean
theorem lipschitz_pair_max
  {n m₁ m₂ : ℕ}
  {f : (Fin n → ℝ) → Fin m₁ → ℝ}
  {g : (Fin n → ℝ) → Fin m₂ → ℝ}
  {Kf Kg : ℝ}
  (hf : IsLipschitzWithLinfVec Kf f)
  (hg : IsLipschitzWithLinfVec Kg g) :
  IsLipschitzWithLinfProd (max Kf Kg) (fun x => (f x, g x))
```

or, if your downstream affine map is bounded in the `ℓ∞→ℓ∞` operator norm by row-sum estimates and it is easier to avoid product sup-norm identities, prove the weaker but very usable bound

```lean
theorem lipschitz_pair_add
  ...
  IsLipschitzWithLinfProd (Kf + Kg) (fun x => (f x, g x))
```

Then compose with an affine map after concatenation:

```lean
theorem affine_after_concat_lipschitz
  {n m₁ m₂ : ℕ}
  {f : (Fin n → ℝ) → Fin m₁ → ℝ}
  {g : (Fin n → ℝ) → Fin m₂ → ℝ}
  {A₁ : Matrix (Fin 1) (Fin m₁) ℝ}
  {A₂ : Matrix (Fin 1) (Fin m₂) ℝ}
  {b : ℝ}
  {Kf Kg KA : ℝ}
  ...
  : IsLipschitzWithLinf (KA * max Kf Kg)
      (fun x => ∑ i, A₁ 0 i * f x i + ∑ j, A₂ 0 j * g x j + b)
```

This theorem is the mathematically meaningful formal avatar of “concatenate channels, then apply an affine map”: the concatenation itself does not amplify the `L∞` budget beyond a norm-controlled aggregation of branch constants.

### Concrete proof strategy

1. **Topological induction on nodes.**  
   Prove `∀ v, IsLipschitzWithLinf (K v) (F v)` by strong induction on `rank v`. The DAG hypothesis `u ∈ parents v → rank u < rank v` gives the induction hypotheses for all parents of `v`. This is the crucial graph-theoretic replacement for ordinary layer-by-layer induction.

2. **Primitive propagation lemmas.**  
   Isolate and prove reusable lemmas:
   - affine composition: `x ↦ a * f x + b` is `|a| * K`-Lipschitz;
   - ReLU is `1`-Lipschitz on `ℝ`:  
     `|max a 0 - max b 0| ≤ |a - b|`;
   - finite sums preserve Lipschitz constants by summation:  
     if each `f_u` is `K_u`-Lipschitz, then `x ↦ ∑ u, f_u x` is `(∑ u, K_u)`-Lipschitz.
   
   The sum lemma is the engine for additive merge nodes and also for affine maps written coordinatewise.

3. **Concatenation/product norm control.**  
   Prove a sup-norm estimate for paired outputs. In `ℓ∞`, the natural constant is `max Kf Kg` because  
   `‖(f x, g x) - (f z, g z)‖∞ = max (‖f x - f z‖∞) (‖g x - g z‖∞)`.  
   If Lean’s norm on product types is inconvenient, encode the needed estimate directly for the downstream scalar affine map, bypassing a full product-space norm formalization.

4. **Logit-difference stability.**  
   For each class `j ≠ y`, define `g_{y,j}(x) = f x y - f x j`. Apply the scalar DAG theorem to each coordinate or use a coordinatewise corollary to show
   `|g_{y,j}(x+δ) - g_{y,j}(x)| ≤ 2 * K_DAG * ‖δ‖∞`.
   Then from `g_{y,j}(x) > 0` and `‖δ‖∞ < g_{y,j}(x)/(2*K_DAG)` deduce `g_{y,j}(x+δ) > 0`.

5. **Pass from pairwise bounds to multiclass certification via finite minimum.**  
   Let `gap(x) = min_{j ≠ y} g_{y,j}(x)`. Since every pairwise gap decreases by at most `2*K_DAG*ε`, positivity of `gap(x) - 2*K_DAG*ε` implies the predicted class is unchanged. The final theorem should package this as a certified radius lower bound
   `gap(x) / (2 * K_DAG)`.

### Key lemmas worth proving separately

These are likely to be broadly reusable in the tropical/robustness library:

```lean
theorem abs_max_zero_sub_max_zero_le_abs_sub (a b : ℝ) :
  |max a 0 - max b 0| ≤ |a - b|

theorem lipschitz_sum_finset
  {α : Type} [DecidableEq α] {s : Finset α}
  {K : α → ℝ} {f : α → (Fin n → ℝ) → ℝ}
  (hK : ∀ i ∈ s, 0 ≤ K i)
  (hf : ∀ i ∈ s, IsLipschitzWithLinf (K i) (f i)) :
  IsLipschitzWithLinf (∑ i in s, K i) (fun x => ∑ i in s, f i x)

theorem lipschitz_sub
  {f g : (Fin n → ℝ) → ℝ} {Kf Kg : ℝ}
  (hf : IsLipschitzWithLinf Kf f)
  (hg : IsLipschitzWithLinf Kg g) :
  IsLipschitzWithLinf (Kf + Kg) (fun x => f x - g x)

theorem margin_positive_under_perturbation
  {g : Fin c → (Fin n → ℝ) → ℝ} {m K ε : ℝ} {x z : Fin n → ℝ}
  (hK : 0 ≤ K)
  (hgz : ∀ j, |g j z - g j x| ≤ K * ‖z - x‖∞)
  (hm : ∀ j, m ≤ g j x)
  (hε : ‖z - x‖∞ ≤ ε) :
  ∀ j, m - K * ε ≤ g j z
```

The last lemma abstracts the perturbation argument and should simplify the multiclass proof.

### Significance

This theorem would be a real extension of the current program, not just a cosmetic generalization. The existing residual-network results treat essentially path-like compositions with local skip edges. A DAG theorem captures modern architectures where information branches and recombines repeatedly: multi-branch ResNets, DenseNet-style concatenations, and arbitrary feed-forward skip graphs. The dynamic-programming quantity `K_DAG` is exactly the right invariant: it is architecture-aware, compositional, and computable from local node rules. Formalizing this would create a reusable certification framework in Lean for tropical piecewise-linear networks with nontrivial graph topology, and it gives a mathematically clean bridge from tropical linear-region control to certified adversarial robustness.

A strong final corollary should explicitly recover the chain/residual theorem as the special case where:
- each `parents v` is either a singleton or `{u,w}` with one predecessor the immediate previous layer,
- there are no concatenation nodes,
- the topological order is the natural layer index.

That specialization theorem is valuable because it validates that the DAG framework is the correct strict generalization of the already verified residual results.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: MachineLearning
Research mode: prove
