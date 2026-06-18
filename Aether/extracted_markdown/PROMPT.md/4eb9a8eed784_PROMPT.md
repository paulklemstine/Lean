Create one clean Lean 4 file formalizing a self-contained finite multigraph handshake theorem, with 0 sorries and no extraneous declarations.

Target file idea: `Catalog/Bridges/MultigraphHandshake.lean`.

Requirements:
1. Import only what you need from Mathlib.
2. Work in a namespace such as `Catalog.Bridges`.
3. Define a structure
   `Multigraph (nV nE : ℕ)`
   with fields
   `src : Fin nE → Fin nV`
   `dst : Fin nE → Fin nV`.
4. Inside a namespace for a fixed `G : Multigraph nV nE`, define:
   - `incidenceCount (v : Fin nV) (e : Fin nE) : ℕ := (if G.src e = v then 1 else 0) + (if G.dst e = v then 1 else 0)`
   - `degree (v : Fin nV) : ℕ := ∑ e : Fin nE, G.incidenceCount v e`
   - `oddVerts : Finset (Fin nV) := Finset.univ.filter (fun v => Odd (G.degree v))`
5. Prove the following theorems, with complete proofs:
   - `sum_incidenceCount_edge (e : Fin nE) : ∑ v : Fin nV, G.incidenceCount v e = 2`
   - `handshake : ∑ v : Fin nV, G.degree v = 2 * nE`
   - a parity corollary such as `even_total_degree : Even (∑ v : Fin nV, G.degree v)`
   - `even_card_oddVerts : Even G.oddVerts.card`
6. Optional only if straightforward after the above compiles:
   - `oddVerts_card_ne_one : G.oddVerts.card ≠ 1`
7. Do NOT include any unrelated theorems, placeholders, malformed declarations, or references to Euler trails.
8. Prefer elementary `Finset` proofs over ambitious abstractions. A good strategy is:
   - first prove each of the two indicator sums over `Fin nV` is 1,
   - then deduce each edge contributes 2,
   - swap the order of summation for handshake,
   - then prove evenness of the odd-degree set by reducing the total degree sum mod 2 and using that `∑ v in oddVerts, 1 ≡ ∑ v, degree v [MOD 2]`.
9. If a direct theorem about `Odd`/`Even` on filtered finsets is awkward, introduce a helper lemma stating that for each natural number `k`, `k % 2` equals `1` iff `Odd k` and `0` iff `Even k`, and use `Finset.sum_congr` over `univ` with the function `fun v => G.degree v % 2`.
10. The final deliverable must be a single compilable Lean file.

Important scope control: the main objective is the handshake theorem and parity of the number of odd-degree vertices for this explicit `Fin`-indexed multigraph model. Do not attempt a broader graph API or any theorem about uniqueness of two odd vertices unless everything else is already complete and simple.