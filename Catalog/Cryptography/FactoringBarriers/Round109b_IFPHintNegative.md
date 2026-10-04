# Round 109b — the IFP hint lattice: an honest failed re-derivation (guard fires again)

**2026-10-04. NO new algorithm. This round records a FAILED attempt, honestly.** I
tried to derive and replicate the *subtle* Implicit-Factorization bound (factor
`N₁` from a hint `z = p₁ − p₂`, using a 2-modulus lattice) with the validated
Coppersmith lattice from round 97f. My derivation was **wrong**, the data caught
it, and I am recording it rather than shipping an unverified claim.

Empirical companion: `Experiments/UMWWindow/implicit_hint.py` (deterministic,
`out_hint.txt`).

---

## 1. The attempt

Round 109 verified the **crisp** IFP corollary: with the exact shared low part
`a` known and `w ≥ α`, `q₁ = N₁·a⁻¹ mod 2^w` and `p₁ = N₁/q₁` in **polynomial
time**. The published *subtle* bound (`t ≈ 2α`; Nuida–Itakura–Kurosawa ePrint
2014/839, Feng–Nitaj–Pan ePrint 2023/1562) replaces the exact shared part with a
**hint** `z = p₁ − p₂` and recovers the rest with a **2-modulus lattice**
(May–Ritzenhofen, PKC'09).

## 2. My derivation was wrong — and the data said so

I claimed: *hint `z' ≡ a (mod 2^v)` ⟹ `q₁ = q₁₀ + 2^v·j`; since `p₁ = N₁/q₁`
divides `N₁`, `f(j) = q₁₀ + 2^v·j ≡ 0 (mod p₁)` — a small-root problem.*

This is **false**: at `j = j_true`, `f(j_true) = q₁`, which is **not 0** and
**not a multiple of `p₁`** (since `gcd(q₁, p₁) = 1`). So `f` has **no root modulo
`p₁`**, and the Coppersmith lattice correctly returns nothing. The empirical run
confirms it exactly:

| case | `X = 2^{α−v}` | Coppersmith condition | recovered |
|---|---|---|---|
| `v = 20` | 2⁴ | true | **0/4** |
| `v = 16` | 2⁸ | true | **0/4** |
| `v = alpha` | 2⁰ (trivial) | true | 4/4 |

Only the trivial `j = 0` case (`v = α`, the round-109 corollary) recovers. Every
genuine small-root case fails — **because the polynomial I fed the lattice had
no root.** The data caught the bad derivation before it was recorded as a result:
the **sixth firing** of the round-104 guard.

## 3. What the correct reduction actually is

The genuine May–Ritzenhofen hint attack is **not** a univariate small-root
problem. With `z = p₁ − p₂`,
$$N_1 q_2 - N_2 q_1 = q_1 q_2 (p_1 - p_2) = z\, q_1 q_2,$$
coupling the **two** cofactors `q₁, q₂` in a genuine **bivariate / 2-modulus**
lattice. Recovering it requires the exact published construction — it must be
taken from May–Ritzenhofen (2009) and the later refinements, **not re-invented**.
I have not reproduced it, so I do not claim it.

## 4. Honest scope

* **No new algorithm this round.** The round-109 polynomial-time IFP corollary
  **stands** and remains verified (8/8); nothing here disturbs it.
* The **subtle hint-based 2-modulus IFP bound is left OPEN** — it needs the
  published construction, and this round's contribution is the honest record that
  a plausible-looking shortcut derivation is **wrong** (a self-contained warning
  for any future attempt).
* **Not claimed:** any improvement from partial hints beyond round 109.

**Next attack (if continuing IFP).** Obtain and implement **May–Ritzenhofen
PKC'09**'s exact 2-modulus lattice (or the `t = 2α − O(log κ)` refinement), verify
it recovers `p₁` from a hint, then test whether the catalog's validated Coppersmith
lattice can strengthen the bound. That is a well-posed target — but it requires
the precise construction, which I declined to guess here for good reason.