## Research Task: Effective finite-quotient injectivity for bounded Berggren words and hardness transfer to SPB key recovery

Research Mode: PROVE

Work in the concrete Berggren `SL₂(ℤ)` embedding already established: the three Berggren generators
`B₁ B₂ B₃ : Matrix (Fin 2) (Fin 2) ℤ`
generate a free semigroup, and reduced words have unique normal forms and faithful evaluation into `SL₂(ℤ)`.

The target is an **effective residual-finiteness theorem** for bounded Berggren words, with an explicit modulus threshold, and then a **cryptographic reduction** showing that inversion of SPB public keys in the quotient is equivalent to canonical word recovery on the bounded keyspace.

### 1. Precise theorem package to prove

You should introduce a concrete word datatype if one is not already present, e.g.
```lean
inductive BergWord
| nil : BergWord
| cons : Fin 3 → BergWord → BergWord
```
together with:
```lean
def BergWord.length : BergWord → ℕ
def BergWord.eval : BergWord → Matrix (Fin 2) (Fin 2) ℤ
```
where `eval` multiplies the chosen Berggren generators.

If the catalog already has a word type / evaluation map / freeness theorem, reuse it exactly instead of redefining it.

The core statements should have Lean signatures close to the following.

#### A. Uniform entry-growth upper bound
Define a max-entry norm on `2×2` integer matrices:
```lean
def matSupNorm (M : Matrix (Fin 2) (Fin 2) ℤ) : ℕ :=
  max (Int.natAbs (M 0 0))
    (max (Int.natAbs (M 0 1))
      (max (Int.natAbs (M 1 0)) (Int.natAbs (M 1 1))))
```
Then prove there is an explicit constant `C ≥ 2` such that every Berggren generator multiplies this norm by at most `C`, hence:
```lean
theorem berggren_eval_supNorm_le_pow
    (C : ℕ)
    (hC : ∀ i : Fin 3, ∀ M : Matrix (Fin 2) (Fin 2) ℤ,
      matSupNorm (M ⬝ berggrenGen i) ≤ C * matSupNorm M)
    (w : BergWord) :
    matSupNorm (BergWord.eval w) ≤ C ^ w.length := by
```
A cleaner version with a fixed explicit `C` is preferable; e.g. compute the row-sum bound of each `Bᵢ` and take the maximum.

You also want the same bound for differences of two bounded words:
```lean
theorem berggren_eval_diff_supNorm_le
    (C : ℕ) (hC : 1 ≤ C)
    (u v : BergWord) :
    matSupNorm (BergWord.eval u - BergWord.eval v)
      ≤ C ^ u.length + C ^ v.length := by
```
and in particular for `u.length ≤ L`, `v.length ≤ L`:
```lean
theorem berggren_eval_diff_supNorm_le_of_length_le
    (C L : ℕ) (hC : 1 ≤ C)
    {u v : BergWord}
    (hu : u.length ≤ L) (hv : v.length ≤ L) :
    matSupNorm (BergWord.eval u - BergWord.eval v) ≤ 2 * C ^ L := by
```

#### B. Effective injectivity modulo large `q`
Define reduction entrywise modulo `q` into `ZMod q`:
```lean
def reduceMod (q : ℕ) :
    Matrix (Fin 2) (Fin 2) ℤ → Matrix (Fin 2) (Fin 2) (ZMod q)
```
Then prove the key separation lemma:

```lean
theorem reduceMod_eq_of_small_difference
    {q : ℕ} (hq : 0 < q)
    {A B : Matrix (Fin 2) (Fin 2) ℤ}
    (hEq : reduceMod q A = reduceMod q B)
    (hsmall : matSupNorm (A - B) < q) :
    A = B := by
```

The intended proof is entrywise: if the reductions agree, then every entry difference is divisible by `q`; if its absolute value is strictly less than `q`, it must be zero.

Then combine this with the freeness/faithfulness theorem for Berggren words:

```lean
theorem berggren_reduce_injective_on_length_le
    (C L q : ℕ)
    (hq : 0 < q)
    (hsep : 2 * C ^ L < q)
    {u v : BergWord}
    (hu : u.length ≤ L) (hv : v.length ≤ L)
    (hred : reduceMod q (BergWord.eval u) = reduceMod q (BergWord.eval v)) :
    u = v := by
```

This should proceed by:
1. showing `BergWord.eval u = BergWord.eval v` via `reduceMod_eq_of_small_difference`,
2. using the already proved faithfulness / unique normal form theorem to conclude `u = v`.

A useful corollary is injectivity of the reduction map on the finite keyspace:
```lean
def BergWord.bounded (L : ℕ) := {w : BergWord // w.length ≤ L}

theorem berggren_reduce_injective_bounded
    (C L q : ℕ) (hq : 0 < q) (hsep : 2 * C ^ L < q) :
    Function.Injective (fun w : BergWord.bounded L =>
      reduceMod q (BergWord.eval w.1)) := by
```

#### C. Canonical decoding on the bounded image
Once injectivity is proved, define a canonical partial inverse on the image:
```lean
def berggrenDecodeBounded
    (L q : ℕ) :
    Matrix (Fin 2) (Fin 2) (ZMod q) → Option (BergWord.bounded L)
```
The exact implementation can be noncomputable if needed, using finite search over bounded words or `Classical.choose` from injectivity on the image.

Then prove correctness:
```lean
theorem berggrenDecodeBounded_correct
    (C L q : ℕ) (hq : 0 < q) (hsep : 2 * C ^ L < q)
    (w : BergWord.bounded L) :
    berggrenDecodeBounded L q (reduceMod q (BergWord.eval w.1)) = some w := by
```
or, if definitional equality of the chosen decoder is awkward, prove the weaker but sufficient:
```lean
theorem berggrenDecodeBounded_spec
    (C L q : ℕ) (hq : 0 < q) (hsep : 2 * C ^ L < q)
    (w : BergWord.bounded L) :
    ∃ w' : BergWord.bounded L,
      berggrenDecodeBounded L q (reduceMod q (BergWord.eval w.1)) = some w' ∧ w' = w := by
```

#### D. Hardness transfer / inversion equivalence
Formalize a simple notion of bounded key-recovery adversary as a left-inverse on the public-key map:
```lean
def PubKey (q : ℕ) := Matrix (Fin 2) (Fin 2) (ZMod q)

def spbPublicMap (q : ℕ) (w : BergWord) : PubKey q :=
  reduceMod q (BergWord.eval w)

def RecoversBoundedKeys (L q : ℕ)
    (A : PubKey q → Option (BergWord.bounded L)) : Prop :=
  ∀ w : BergWord.bounded L, A (spbPublicMap q w.1) = some w
```

Then show that under the injectivity threshold, key recovery is equivalent to canonical decoding on the image:
```lean
theorem bounded_key_recovery_equiv_decoder
    (C L q : ℕ) (hq : 0 < q) (hsep : 2 * C ^ L < q) :
    ∃ A : PubKey q → Option (BergWord.bounded L),
      RecoversBoundedKeys L q A := by
```
and, more structurally,
```lean
theorem any_bounded_inverter_agrees_on_image
    (C L q : ℕ) (hq : 0 < q) (hsep : 2 * C ^ L < q)
    {A : PubKey q → Option (BergWord.bounded L)}
    (hA : RecoversBoundedKeys L q A) :
    ∀ w : BergWord.bounded L,
      A (spbPublicMap q w.1) = berggrenDecodeBounded L q (spbPublicMap q w.1) := by
```

If the SPB side is already formalized as a cyclic-action public-key map `spbPow : α → ℕ → α` or similar, specialize the theorem to the Berggren-embedded public element and prove a reduction theorem of the shape:
```lean
theorem spb_dlog_reduces_to_berggren_word_recovery
    (C L q : ℕ) (hq : 0 < q) (hsep : 2 * C ^ L < q)
    (g : PubKey q)
    (encode : BergWord.bounded L → ℕ)
    (hencode_inj : Function.Injective encode)
    (hpub : ∀ w : BergWord.bounded L, spbPublicElem q (encode w) = spbPublicMap q w.1) :
    ∀ A : PubKey q → Option (BergWord.bounded L),
      RecoversBoundedKeys L q A →
      ∃ B : PubKey q → Option ℕ,
        ∀ w : BergWord.bounded L,
          B (spbPublicElem q (encode w)) = some (encode w) := by
```
This is the right formal meaning of “recovering the Berggren normal form is at least as hard as recovering the SPB discrete-log exponent” on the bounded injective parameter range.

### 2. Concrete proof strategy

1. **Choose an explicit operator norm constant for the generators.**  
   Compute, for each Berggren generator `Bᵢ`, a simple coefficient bound such as
   \[
   \|M Bᵢ\|_\infty \le C \|M\|_\infty
   \]
   where `C` is the maximum row-sum or entrywise `ℓ¹` bound of the three `Bᵢ`. Since the matrices are fixed, this should be a finite explicit arithmetic verification. This avoids any spectral-radius machinery and gives a clean induction on word length.

2. **Prove the bounded-difference lemma by triangle inequality on entries.**  
   For `A = eval u` and `B = eval v`, each entry of `A - B` has absolute value bounded by the sum of the corresponding entry bounds for `A` and `B`. Hence
   \[
   \|A-B\|_\infty \le \|A\|_\infty + \|B\|_\infty \le C^{|u|}+C^{|v|} \le 2C^L.
   \]
   In Lean, this is best done by proving entrywise `Int.natAbs` inequalities and then folding them into `matSupNorm`.

3. **Exploit divisibility plus smallness to force zero.**  
   From
   `reduceMod q A = reduceMod q B`,
   derive for each entry `(i,j)` that
   `((A - B) i j : ℤ)` is divisible by `q`.
   Use a lemma of the form:
   ```lean
   theorem int_eq_zero_of_dvd_of_natAbs_lt
       {z : ℤ} {q : ℕ} (hq : 0 < q)
       (hdvd : (q : ℤ) ∣ z) (hsmall : Int.natAbs z < q) : z = 0
   ```
   This is the critical arithmetic step. Once each entry difference vanishes, matrix extensionality gives `A = B`.

4. **Transfer matrix equality back to word equality using existing freeness.**  
   The point is not just injectivity of evaluation globally, but effective injectivity after reduction. Once `eval u = eval v`, invoke the catalog theorem giving unique normal forms / faithful Berggren embedding to conclude `u = v`. This is where the semigroup-theoretic content enters; the finite-quotient theorem should genuinely depend on the previously proved free-semigroup structure.

5. **Package the injectivity as a decoder / inversion theorem on the bounded image.**  
   Since words of length `≤ L` form a finite type or at least a finite list, define a canonical decoder by finite search over bounded words, checking whether the reduced matrix matches. Injectivity ensures uniqueness. This lets you state a rigorous cryptographic consequence: any algorithm that inverts public keys on this bounded image computes the unique normal form, and any encoding of those normal forms into exponents yields a discrete-log solver on the corresponding cyclic image.

### 3. Important auxiliary lemmas worth isolating

These arithmetic and matrix lemmas will likely make the development much smoother:

```lean
theorem int_natAbs_lt_of_mem_matSupNorm
    {M : Matrix (Fin 2) (Fin 2) ℤ} {i j : Fin 2} :
    Int.natAbs (M i j) ≤ matSupNorm M := by
```

```lean
theorem matSupNorm_sub_le
    (A B : Matrix (Fin 2) (Fin 2) ℤ) :
    matSupNorm (A - B) ≤ matSupNorm A + matSupNorm B := by
```

```lean
theorem reduceMod_eq_iff_entrywise_dvd
    {q : ℕ} (hq : 0 < q)
    {A B : Matrix (Fin 2) (Fin 2) ℤ} :
    reduceMod q A = reduceMod q B ↔
      ∀ i j, ((q : ℤ) ∣ (A i j - B i j)) := by
```

```lean
theorem bounded_words_finite (L : ℕ) :
    (Set.Finite {w : BergWord | w.length ≤ L}) := by
```
or an explicit `Fintype` instance for `BergWord.bounded L`.

If the word type is represented as `List (Fin 3)`, the bounded finiteness theorem becomes especially easy using `List.Vector` or bounded-length lists.

### 4. Why this matters

This theorem is the right next step for the Berggren/SPB program because it upgrades the existing **qualitative** algebraic embedding (`free semigroup`, `faithful normal forms`) to an **effective finite-quotient separation statement** with a usable modulus threshold `q > 2 C^L`. That is precisely the form needed for cryptographic applications.

The mathematical gain is twofold:

- it gives an explicit residual-finiteness result for the Berggren semigroup inside `SL₂(ℤ)`, not just existence of finite quotients separating distinct elements;
- it turns the semigroup normal-form theorem into a concrete bounded-key injectivity theorem, allowing one to formalize that quotient public keys retain the full information of the underlying Berggren word as long as parameters stay below the collision threshold.

The cryptographic gain is equally important: once reduction modulo `q` is injective on the keyspace, **key recovery in the quotient is exactly canonical word recovery**, and any exponent encoding of those words inherits this hardness. This provides a clean formal bridge from the Berggren-tree algebra to SPB Diffie–Hellman style hardness assumptions, without waiting on unrelated cancellation/divisibility developments. It is the first theorem in this direction that is both algebraically nontrivial and directly parameterized for finite-quotient cryptography.

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

Research domain: Cryptography
Research mode: prove
