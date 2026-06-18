## Research Task: GL₃ tropical Satake reconstruction from rank-2 Levi convolution profiles and Weyl-chamber edge moments

**Research Mode: PROVE**

Work in a concrete finite-dimensional model of dominant GL₃ coweights so that the theorem is genuinely formalizable and does not depend on undeclared representation-theoretic infrastructure. A good choice is the dominant chamber
\[
\Lambda^+_3 := \{(a,b,c)\in \mathbb N^3 \mid a \ge b \ge c\},
\]
or equivalently the translated two-parameter form
\[
\{(x,y)\in \mathbb N^2\}
\]
via \((a,b,c)=(x+y,y,0)\). The latter is often easier for convolution along simple-root directions. Use finitely supported functions into `ℝ` (or `ℤ` if the existing tropical-convolution API is integral-valued).

The target is a **reconstruction/faithfulness theorem**: equality of all rank-2 Levi triple-convolution profiles together with equality of the three edge-moment families forces equality of the original finitely supported dominant-chamber data.

### Suggested concrete model and definitions

Represent dominant coweights by:
```lean
def DomGL3 := {v : ℕ × ℕ × ℕ // v.1 ≥ v.2.1 ∧ v.2.1 ≥ v.2.2}
```
or, if simpler for chamber coordinates,
```lean
abbrev DomTri := ℕ × ℕ
```
with interpretation `(x,y)` corresponding to the dominant coweight `(x+y, y, 0)`.

Define finitely supported tropical Hecke data as:
```lean
abbrev HeckeData := DomTri →₀ ℝ
```

Define the two simple-root Levi rays:
- first ray changes the first chamber coordinate,
- second ray changes the second chamber coordinate.

For instance on `DomTri = ℕ × ℕ`:
```lean
def leviRay1 (t : ℕ) : HeckeData := Finsupp.single (t, 0) 1
def leviRay2 (u : ℕ) : HeckeData := Finsupp.single (0, u) 1
```
or more generally any already-existing “tropical Levi test family” in the codebase, provided it is supported on these rays and has enough normalization to make convolution readable.

Use additive convolution on the dominant semigroup:
```lean
def tconv (f g : HeckeData) : HeckeData := ...
```
with coefficient at `(x,y)` equal to the finite sum over splittings `(a,b)+(c,d)=(x,y)`.

Then the key theorem should have an exact Lean-facing shape similar to:
```lean
theorem reconstruct_from_rank2_profiles_and_edge_moments
    (f g : HeckeData)
    (hprof :
      ∀ t u : ℕ, tconv (tconv f (leviRay1 t)) (leviRay2 u) =
                 tconv (tconv g (leviRay1 t)) (leviRay2 u))
    (hedge_x :
      ∀ m : ℕ, ∑' n : ℕ, f (m,n) = ∑' n : ℕ, g (m,n)) -- replace by finite edge moment if preferred
    (hedge_y :
      ∀ m : ℕ, ∑' n : ℕ, f (n,m) = ∑' n : ℕ, g (n,m))
    (hedge_diag :
      ∀ m : ℕ, ∑' n : ℕ, f (n + m, n) = ∑' n : ℕ, g (n + m, n)) :
    f = g := by
  ...
```

However, because `f` and `g` are finitely supported, it is usually better to avoid infinite sums and define **edge moments as finite sums over support slices**:
```lean
def edgeMomentX (f : HeckeData) (m : ℕ) : ℝ :=
  ∑ y in f.support.image Prod.snd, f (m, y)

def edgeMomentY (f : HeckeData) (m : ℕ) : ℝ :=
  ∑ x in f.support.image Prod.fst, f (x, m)

def edgeMomentDiag (f : HeckeData) (m : ℕ) : ℝ :=
  ∑ y in (f.support.filter fun p => p.1 ≥ p.2 + m).image Prod.snd, f (y + m, y)
```
A cleaner alternative is to define moments against explicit edge test functions and phrase hypotheses as equality of all evaluations:
```lean
def edgeTestX (m : ℕ) : HeckeData := ...
def edgeTestY (m : ℕ) : HeckeData := ...
def edgeTestDiag (m : ℕ) : HeckeData := ...

theorem reconstruct_from_profiles_and_edge_tests
    (f g : HeckeData)
    (hprof : ∀ t u : ℕ,
      tconv (tconv f (leviRay1 t)) (leviRay2 u) =
      tconv (tconv g (leviRay1 t)) (leviRay2 u))
    (hx : ∀ m, pairing f (edgeTestX m) = pairing g (edgeTestX m))
    (hy : ∀ m, pairing f (edgeTestY m) = pairing g (edgeTestY m))
    (hd : ∀ m, pairing f (edgeTestDiag m) = pairing g (edgeTestDiag m)) :
    f = g := by
  ...
```

### Precise theorem to aim for

A very robust and likely formalizable statement is the following **difference-reconstruction theorem**. Let `h := f - g`. Then the assumptions imply:
1. all rank-2 Levi triple-convolution profiles of `h` vanish,
2. all edge moments of `h` vanish,
3. therefore `h = 0`.

Formally:
```lean
theorem zero_of_vanishing_rank2_profiles_and_edge_moments
    (h : HeckeData)
    (hprof : ∀ t u : ℕ,
      tconv (tconv h (leviRay1 t)) (leviRay2 u) = 0)
    (hx : ∀ m : ℕ, edgeMomentX h m = 0)
    (hy : ∀ m : ℕ, edgeMomentY h m = 0)
    (hd : ∀ m : ℕ, edgeMomentDiag h m = 0) :
    h = 0 := by
  ...
```
and then derive reconstruction by applying this to `f - g`.

This reformulation is mathematically cleaner: it converts a faithfulness statement into a kernel-triviality statement.

### Core mathematical insight to formalize

The nontrivial point is that convolution with the two Levi-ray generators detects **rectangular cumulative sums** or **mixed discrete derivatives**, depending on normalization. If `leviRay1 t` and `leviRay2 u` are delta masses, then
\[
((h * \delta_{(t,0)}) * \delta_{(0,u)})(x,y) = h(x-t,y-u),
\]
which is too trivial and gives immediate reconstruction. So you should **not** use pure delta tests if you want a theorem with real content.

Instead define cumulative ray tests:
```lean
def leviSeg1 (t : ℕ) : HeckeData :=
  ∑ i in Finset.range (t+1), Finsupp.single (i,0) 1

def leviSeg2 (u : ℕ) : HeckeData :=
  ∑ j in Finset.range (u+1), Finsupp.single (0,j) 1
```
Then
\[
(h * \mathrm{leviSeg1}(t) * \mathrm{leviSeg2}(u))(x,y)
= \sum_{0\le i\le t,\ 0\le j\le u} h(x-i,y-j),
\]
a 2D cumulative sum. Equality of these profiles for all `t,u` determines the mixed second finite difference of the profile, hence recovers interior coefficients:
\[
h(x,y)=S(x,y)-S(x-1,y)-S(x,y-1)+S(x-1,y-1),
\]
where \(S\) is the appropriate cumulative profile. This is the right tropical/discrete analogue of “rank-2 convolution detects mixed derivatives”.

Thus, a better theorem statement is:

```lean
def leviSeg1 (t : ℕ) : HeckeData := ...
def leviSeg2 (u : ℕ) : HeckeData := ...

theorem reconstruct_from_segment_convolution_profiles
    (f g : HeckeData)
    (hprof : ∀ t u : ℕ,
      tconv (tconv f (leviSeg1 t)) (leviSeg2 u) =
      tconv (tconv g (leviSeg1 t)) (leviSeg2 u))
    (hx : ∀ m : ℕ, edgeMomentX f m = edgeMomentX g m)
    (hy : ∀ m : ℕ, edgeMomentY f m = edgeMomentY g m)
    (hd : ∀ m : ℕ, edgeMomentDiag f m = edgeMomentDiag g m)) :
    f = g := by
  ...
```

If the profile equality is too strong as equality of whole functions, you can weaken it to equality at all chamber points:
```lean
(hprof : ∀ t u x y : ℕ,
  tconv (tconv f (leviSeg1 t)) (leviSeg2 u) (x,y) =
  tconv (tconv g (leviSeg1 t)) (leviSeg2 u) (x,y))
```

### Proof strategy: concrete steps

1. **Pass to the difference function.**  
   Set `h := f - g`. Rewrite all hypotheses as vanishing statements. Reduce the main theorem to:
   ```lean
   suffices hz : h = 0 by
     exact sub_eq_zero.mp hz
   ```
   This makes every subsequent lemma a kernel-triviality statement.

2. **Compute the convolution profile as a finite rectangular sum.**  
   Prove an explicit formula:
   ```lean
   lemma tconv_leviSeg1_leviSeg2_eval
       (h : HeckeData) (t u x y : ℕ) :
       tconv (tconv h (leviSeg1 t)) (leviSeg2 u) (x,y)
         = ∑ i in Finset.range (t+1), ∑ j in Finset.range (u+1),
             if i ≤ x ∧ j ≤ y then h (x-i, y-j) else 0 := by
     ...
   ```
   Then derive the cleaner support-aware version without `if`s when indices are bounded by `x,y`. This is the key computational lemma.

3. **Extract the mixed second-difference identity.**  
   Define
   ```lean
   def rectProfile (h : HeckeData) (x y : ℕ) : ℝ :=
     tconv (tconv h (leviSeg1 x)) (leviSeg2 y) (x,y)
   ```
   and prove:
   ```lean
   lemma mixed_difference_recovers
       (h : HeckeData) (x y : ℕ) :
       h (x,y)
         = rectProfile h x y
         - rectProfile h (x-1) y
         - rectProfile h x (y-1)
         + rectProfile h (x-1) (y-1) := by
     ...
   ```
   In Lean, natural subtraction is awkward; it is often cleaner to split into cases `x = 0`, `y = 0`, and `x.succ`, `y.succ`, or to formulate using `Option`/boundary conventions:
   ```lean
   def rectProfileZ (h : HeckeData) : ℕ → ℕ → ℝ := ...
   ```
   with explicit lemmas for `0` and `Nat.succ`.

4. **Use edge moments to anchor boundary terms.**  
   The mixed-difference formula determines interior coefficients, but boundary slices `x=0`, `y=0`, and the diagonal edge may still need separate control depending on your exact profile normalization. Prove lemmas such as:
   ```lean
   lemma boundary_x_zero_of_edgeMomentX_zero
       (h : HeckeData) (hx : ∀ m, edgeMomentX h m = 0) :
       ∀ y, h (0,y) = 0 := by
     ...

   lemma boundary_y_zero_of_edgeMomentY_zero
       (h : HeckeData) (hy : ∀ m, edgeMomentY h m = 0) :
       ∀ x, h (x,0) = 0 := by
     ...
   ```
   and, if the chamber geometry in your chosen coordinate system needs it, use the diagonal edge moments to control the `x=y+const` boundary family:
   ```lean
   lemma boundary_diag_zero_of_edgeMomentDiag_zero
       ...
   ```

5. **Propagate vanishing from edges to the whole support.**  
   Perform induction on `x + y` (or on the finite support maximum) using the mixed-difference identity. The induction step should show that if all smaller points vanish and the rectangular profile is zero, then `h (x,y)=0`. A clean statement is:
   ```lean
   lemma zero_everywhere_of_zero_profiles_and_boundaries
       (h : HeckeData)
       (hprof : ∀ x y, rectProfile h x y = 0)
       (hx0 : ∀ y, h (0,y) = 0)
       (hy0 : ∀ x, h (x,0) = 0) :
       ∀ x y, h (x,y) = 0 := by
     intro x y
     induction' (x + y) with n ih generalizing x y
     ...
   ```
   Since `h` is finitely supported, you can also use a maximal-support contradiction: choose a support point of maximal `x+y`, show the profile at that point isolates its coefficient, contradiction. This is often more efficient in `Finsupp`.

### Important Lean design choices

- Prefer `DomTri := ℕ × ℕ` unless there is already a dominant-weight API for GL₃ in the project. It makes convolution and edge slices much easier.
- Use `Finsupp` and finite sums over `Finset.range`.
- Avoid infinite sums if possible; finite support makes finite combinatorics natural.
- If subtraction in coefficients causes typeclass friction, work over `ℤ` or `ℝ` with:
  ```lean
  open scoped BigOperators
  ```
- If function equality is the conclusion, finish with:
  ```lean
  ext p
  rcases p with ⟨x,y⟩
  ...
  ```

### Strong intermediate lemmas worth proving

These are valuable in their own right and likely reusable later in the GL₃ tropical Satake program:

```lean
lemma convolution_with_segment_ray_eq_prefix_sum
    (h : HeckeData) (t x y : ℕ) :
    tconv h (leviSeg1 t) (x,y)
      = ∑ i in Finset.range (t+1), if i ≤ x then h (x-i, y) else 0 := by
  ...

lemma double_segment_convolution_eq_rect_sum
    (h : HeckeData) (t u x y : ℕ) :
    tconv (tconv h (leviSeg1 t)) (leviSeg2 u) (x,y)
      = ∑ i in Finset.range (t+1), ∑ j in Finset.range (u+1),
          if i ≤ x ∧ j ≤ y then h (x-i, y-j) else 0 := by
  ...

lemma coefficient_from_rectangular_prefix_sums
    (h : HeckeData) (x y : ℕ) :
    h (x,y)
      = rectProfile h x y
      - rectProfile h x (y-1)
      - rectProfile h (x-1) y
      + rectProfile h (x-1) (y-1) := by
  ...
```

If natural subtraction is awkward, use successor-indexed versions:
```lean
lemma coefficient_from_rectangular_prefix_sums_succ
    (h : HeckeData) (x y : ℕ) :
    h (x.succ, y.succ)
      = rectProfile h (x.succ) (y.succ)
      - rectProfile h x (y.succ)
      - rectProfile h (x.succ) y
      + rectProfile h x y := by
  ...
```
This version is usually much easier.

### Why this matters

This theorem is a genuine step beyond previously isolated uniqueness statements because it shows that **structured tropical convolution probes plus boundary data are already faithful on finitely supported GL₃ dominant Hecke data**. It does not merely compare adjacent facets or rank-1 marginals; it demonstrates a reconstruction mechanism from rank-2 Levi information. That is exactly the right finite-combinatorial analogue of a tropical Satake “trace-determines-function” principle.

Formally, this gives:
- a reusable **convolution-faithfulness** result for GL₃,
- a bridge from surjectivity/uniqueness phenomena to a full **reconstruction theorem**,
- a clean template for later extension to higher rank by replacing mixed second differences with higher-dimensional discrete derivative recovery.

### File target

`Tropical/Langlands/GL3_ReconstructionFromRank2LeviProfiles.lean`

A good final theorem name would be one of:
```lean
theorem reconstruct_from_rank2Levi_profiles_and_edge_moments ...
theorem rank2Levi_profile_faithful_with_edge_moments ...
theorem gl3_tropical_satake_reconstruction ...
```

The most promising route is: define segment-ray tests, prove the rectangular-prefix-sum formula, extract coefficients by finite differences, use edge moments only for boundary anchoring, then conclude `f = g` by extensionality.

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

Research domain: Tropical
Research mode: prove
