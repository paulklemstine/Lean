# Computational Evidence — Regular 4‑maniplexes and the tetravalent census

## 1. Small‑case calculations

A rank‑`n` maniplex is a flag set with `n` fixed‑point‑free involutions
`r₀,…,r_{n-1}`; for a regular one the flags biject with the connection group and
`#flags = |group|`.

| Polytope / maniplex (rank 4) | # facets/vertices | # flags | flag graph valence |
|------------------------------|-------------------|---------|--------------------|
| 4‑simplex `{3,3,3}`          | 5 vertices        | 120     | 4                  |
| 4‑cube `{4,3,3}`             | 16 vertices       | 384     | 4                  |
| 4‑orthoplex `{3,3,4}`        | 8 vertices        | 384     | 4                  |
| 24‑cell `{3,4,3}`            | 24 vertices       | 1152    | 4                  |
| 120‑cell `{5,3,3}`           | 600 vertices      | 14400   | 4                  |

In every case the flag count is even and the flag graph is 4‑regular
(tetravalent), matching theorems `even_card_flags` and `flagGraph_tetravalent`.

## 2. Structural checks (non‑adjacent colour classes)

For the 4‑cube, taking colours `i = 0, j = 2` (indices differ by 2), the orbit of
any flag `f` under `⟨r₀, r₂⟩` is exactly `{f, r₀f, r₂f, r₀r₂f}` — four distinct
flags closed under `r₀` and `r₂`. This is a 4‑gon, confirming
`string_generates_fourgon`. The same holds for pairs `(0,3)` and `(1,3)`.

## 3. Counterexample hunt (the literal census‑equinumerosity claim)

The mission's literal claim — that the number of regular 4‑maniplexes equals the
number of tetravalent graphs in Potočnik's census — is **false**:

* Potočnik's census enumerates connected tetravalent graphs up to a bounded
  order (e.g. ≤ 1280 vertices for arc‑transitive ones); regular 4‑maniplexes
  form an *unbounded* family (the flag graphs above already reach 14400 vertices
  and grow without bound), so the two counts cannot be equal.
* A census graph carries no canonical proper 4‑edge‑colouring, and a generic
  tetravalent graph admits none whose non‑adjacent classes bound 4‑gons, so not
  every census entry is a maniplex flag graph.

What *is* true and is proved here is the well‑defined direction: every rank‑4
maniplex yields an even‑order, 4‑regular, properly 4‑edge‑coloured graph whose
non‑adjacent colour classes bound 4‑gons. This is the salvaged, verifiable core
of the conjecture.

## 4. OEIS

The flag counts `120, 384, 384, 1152, 14400` are `#vertices · 24` for the regular
4‑polytopes; the sequence of regular convex 4‑polytope flag counts is finite
(there are exactly six). No single OEIS entry captures the full maniplex family,
consistent with its unboundedness.
