# The Wide-Trail Strategy, Formalized: Four Rounds of AES Activate at Least 25 S-boxes, Tightly

**Author:** Aristotle

**Domain:** Symmetric-key cryptanalysis / Provable security

## Abstract

The security of the Advanced Encryption Standard (AES) against differential and
linear cryptanalysis rests on the *wide-trail strategy* of Daemen and Rijmen,
whose centerpiece is the claim that any four-round differential (or linear)
trail activates at least 25 S-boxes. Combined with the maximal differential
probability $2^{-6}$ of the AES S-box, this caps the probability of any
four-round trail at $(2^{-6})^{25} = 2^{-150}$, far below the $2^{-128}$ needed
for security. We present a self-contained, formally verified development of this
result. Working with AES states as $4 \times 4$ arrays over an abstract field,
we define the column-weight machinery, prove a generic *round bound* relating
active columns to active bytes through the MixColumns branch number $B$, and
chain two rounds together with a super-box branch hypothesis to obtain a generic
$B^2$ lower bound. Specializing to the AES branch number $B = 5$ yields the
headline bound of $25$ active S-boxes. We further establish *tightness*: an
explicit $1\text{-}4\text{-}16\text{-}4$ trail satisfies every hypothesis and
activates exactly 25 S-boxes, so the minimum is precisely 25. The sole
non-elementary ingredient — that the AES super-box (two middle rounds) is MDS
with branch number 5 — is isolated as an explicit hypothesis, and we discuss the
coding-theoretic program for discharging it. The development is fully
machine-checked, with finite claims discharged by exhaustive evaluation.

## 1. Introduction

### 1.1 Differential and linear cryptanalysis

Differential cryptanalysis (Biham–Shamir, 1990) and linear cryptanalysis
(Matsui, 1993) are the two most influential generic attacks on block ciphers.
Both attempt to detect a statistical deviation from randomness that propagates
through the rounds of a cipher along a *trail*. In differential cryptanalysis,
the analyst fixes an input difference $a \neq 0$ and tracks the probability that
it evolves into a chosen output difference; in linear cryptanalysis, the analyst
tracks the correlation of a linear approximation built from input, output, and
key bits. In both cases, the attack's cost is governed by the best trail's
probability (respectively, squared correlation), which decomposes as a product
over the nonlinear components — the **S-boxes** — that the trail *activates*.

An S-box is **active** in a trail when the difference (or mask) entering it is
nonzero. If the per-S-box differential probability is bounded by $p_{\max}$ and
a trail must activate at least $N$ S-boxes, then the trail probability is at most
$p_{\max}^N$. For AES, $p_{\max} = 2^{-6}$ (the S-box has differential
uniformity 4), so a guaranteed $N = 25$ active S-boxes over four rounds gives a
trail bound of $2^{-150}$. Against a 128-bit cipher, where an exploitable trail
must exceed roughly $2^{-128}$, this is a decisive margin.

### 1.2 The wide-trail strategy

Daemen and Rijmen designed AES (originally Rijndael) around the *wide-trail
strategy*: rather than maximizing the nonlinearity of individual S-boxes, design
the linear diffusion layer so that *the number of active S-boxes is provably
large*. The strategy reduces a probabilistic security claim to a combinatorial
counting problem governed by the **branch number** of the diffusion layer.

The AES round operates on a $4 \times 4$ byte array (the *state*) via four steps:
SubBytes (apply the S-box bytewise), ShiftRows (cyclically shift row $i$ by $i$),
MixColumns (left-multiply each column by a fixed MDS matrix over
$\mathrm{GF}(2^8)$), and AddRoundKey (XOR the round key). For trail counting,
SubBytes and AddRoundKey preserve the *activity pattern* (the set of nonzero
positions), so only ShiftRows and MixColumns matter. ShiftRows guarantees that
the four bytes of any column are dispersed to four distinct columns; MixColumns,
being MDS, guarantees a branch number of $5$.

### 1.2b Why four rounds, and why the square

The choice of *four* rounds as the unit of analysis is deliberate. A single AES
round diffuses within columns (MixColumns) and across columns (ShiftRows), but
its worst-case active-S-box count is only the branch number $B$ on a single
active column. Two rounds already raise the floor, but it is the *pairing* of two
two-round halves — each contributing a factor of $B$ — that produces the
multiplicative $B^2$ guarantee. Intuitively, the first half forces an active
column to spread to at least $B$ bytes, and the second half forces each of the
active columns produced by the middle super-box to spread again; the super-box
guarantees that the number of active columns entering the two halves is itself at
least $B$. The product of "$B$ columns" and "$B$ bytes per column" is $B^2$. This
is the conceptual content of the wide-trail strategy, and it is why AES, with
$B = 5$, achieves a four-round floor of $25$ rather than the much weaker linear
growth a naive bound would predict.

### 1.3 Contributions

We give a formal, machine-checked development establishing:

1. A **generic four-round bound** (`four_round_bound`): under a round bound for
   rounds 1 and 3 and a super-box branch hypothesis, the total active-S-box count
   over four rounds is at least $B^2$.
2. The **AES specialization** (`aes_four_round_ge_25`): with the AES branch
   number $B = 5$ and the concrete AES ShiftRows, four rounds activate at least
   25 S-boxes.
3. **Tightness** (`tight_trail_weight`, `aes_four_round_tight`): an explicit
   $1\text{-}4\text{-}16\text{-}4$ trail satisfies all hypotheses and activates
   exactly 25 S-boxes, so the minimum is exactly 25.

All finite verifications (weights, the activity and branch conditions for the
explicit trail) are discharged by exhaustive evaluation over the concrete state
space. The single deep ingredient, the super-box branch property, is isolated as
a hypothesis `hsuper`, and Section 7 outlines its coding-theoretic proof.

## 2. Preliminaries and definitions

We work with states over an abstract type $\alpha$ equipped with a distinguished
$0$ and decidable equality; for AES, $\alpha = \mathrm{GF}(2^8)$, but the
counting arguments need only the zero element. (For the explicit tightness
witness we instantiate $\alpha = \mathbb{Z}/2\mathbb{Z}$, which suffices to model
activity patterns.)

**Definition 2.1 (State).** A *state* of dimensions $r \times c$ is a function
$$ \mathrm{St}\,\alpha\, r\, c \;:=\; \mathrm{Fin}\,r \to \mathrm{Fin}\,c \to \alpha. $$
For AES, $r = c = 4$: a state is a $4 \times 4$ array of field elements indexed
by (row, column). We write $a\, i\, j$ for the byte in row $i$, column $j$.

**Definition 2.2 (Active byte and total weight).** A byte $a\, i\, j$ is
*active* if $a\, i\, j \neq 0$. The *weight* $\mathrm{wt}(a)$ is the number of
active bytes in the state — equivalently, the number of S-boxes the state
activates:
$$ \mathrm{wt}(a) \;=\; \#\{(i,j) : a\, i\, j \neq 0\}. $$

**Definition 2.3 (Column weight and active columns).** The *column weight* of
column $j$ is the number of active bytes in that column,
$$ \mathrm{colWeight}(a)\, j \;=\; \#\{ i : a\, i\, j \neq 0 \}, $$
and the number of *active columns* is
$$ \mathrm{colActive}(a) \;=\; \#\{ j : \exists i,\; a\, i\, j \neq 0 \}. $$
These satisfy $\mathrm{wt}(a) = \sum_j \mathrm{colWeight}(a)\, j$ and
$\mathrm{colActive}(a) \le \mathrm{wt}(a)$.

**Definition 2.4 (ShiftRows).** Given a family of row permutations
$\rho : \mathrm{Fin}\,4 \to \mathrm{Perm}(\mathrm{Fin}\,4)$, the operator
$\mathrm{shiftRows}\,\rho$ permutes the entries within each row:
$$ (\mathrm{shiftRows}\,\rho\, a)\, i\, j \;=\; a\, i\, (\rho_i\, j). $$
The *AES ShiftRows* $\mathrm{aesShiftRows}$ takes $\rho_i$ to be the cyclic
shift of $\mathrm{Fin}\,4$ by $i$, i.e. row $0$ is fixed, row $1$ shifts by one,
row $2$ by two, row $3$ by three. Its defining diffusion property is *optimality*:
the four cells of any single source column land in four distinct destination
columns.

**Definition 2.5 (Branch number).** A column-mixing map $M$ over
$\mathrm{GF}(2^8)^4$ has *branch number* $B$ if for every nonzero column $x$,
$$ \mathrm{wt}(x) + \mathrm{wt}(M x) \;\ge\; B, $$
where $\mathrm{wt}$ here is the Hamming weight (number of nonzero coordinates).
The map is **MDS** (maximum distance separable) iff it attains the maximal
branch number $B = n + 1$ for $n$-coordinate columns; for $n = 4$, the AES
MixColumns matrix is MDS with $B = 5$.

## 3. The round bound

The core lemma relating one round of diffusion to active-byte counts is the
*round bound*. It packages ShiftRows' dispersion together with the MixColumns
branch number.

**Lemma 3.1 (Round bound; `round_bound`).** Let $\rho$ be a ShiftRows family and
let $a \xrightarrow{\text{round}} a'$ be a one-round transition, where the
activity pattern after ShiftRows on $a$ matches the activity pattern of the input
columns to MixColumns producing $a'$. Suppose:

- *(activity)* for every column $j$,
  $\bigl(\exists i,\ (\mathrm{shiftRows}\,\rho\, a)\, i\, j \neq 0\bigr)
  \iff \bigl(\exists i,\ a'\, i\, j \neq 0\bigr)$; and
- *(branch)* for every active column $j$ of $\mathrm{shiftRows}\,\rho\, a$,
  $$ B \le \mathrm{colWeight}(\mathrm{shiftRows}\,\rho\, a)\, j + \mathrm{colWeight}(a')\, j. $$

Then
$$ B \cdot \mathrm{colActive}(a') \;\le\; \mathrm{wt}(a) + \mathrm{wt}(a'). $$

*Proof sketch.* Summing the per-column branch inequality over the active columns
of the output (which, by the activity equivalence, coincide with the active
columns of $\mathrm{shiftRows}\,\rho\,a$) gives
$B \cdot \mathrm{colActive}(a') \le \sum_j \mathrm{colWeight}(\mathrm{shiftRows}\,\rho\,a)\,j + \sum_j \mathrm{colWeight}(a')\,j$.
The first sum equals $\mathrm{wt}(\mathrm{shiftRows}\,\rho\,a) = \mathrm{wt}(a)$,
since ShiftRows is a bijection on cells and preserves the number of nonzero
entries; the second equals $\mathrm{wt}(a')$. $\;\square$

Lemma 3.1 is the workhorse: it converts "active output columns" into a lower
bound on "active bytes consumed by the round," multiplied by the branch number.
The factor $B$ appears once per round.

## 4. The four-round bound (generic)

We now compose two applications of the round bound across rounds 1 and 3, glued
by the behavior of the two middle rounds.

**Theorem 4.1 (Generic four-round bound; `four_round_bound`).** Let $\rho$ be a
ShiftRows family and let $a_1, a_2, a_3, a_4$ be four states forming a four-round
trail. Suppose:

- *(round 1)* the activity and branch conditions of Lemma 3.1 hold for the
  transition $a_1 \to a_2$ with branch number $B$;
- *(round 3)* the activity and branch conditions of Lemma 3.1 hold for the
  transition $a_3 \to a_4$ with branch number $B$;
- *(super-box; `hsuper`)* the two middle rounds satisfy
  $$ B \le \mathrm{colActive}(a_2) + \mathrm{colActive}(a_4). $$

Then
$$ B^2 \;\le\; \mathrm{wt}(a_1) + \mathrm{wt}(a_2) + \mathrm{wt}(a_3) + \mathrm{wt}(a_4). $$

*Proof.* Write $c_2 = \mathrm{colActive}(a_2)$, $c_4 = \mathrm{colActive}(a_4)$.
Lemma 3.1 applied to round 1 gives $B c_2 \le \mathrm{wt}(a_1) + \mathrm{wt}(a_2)$,
and applied to round 3 gives $B c_4 \le \mathrm{wt}(a_3) + \mathrm{wt}(a_4)$.
The super-box hypothesis gives $B \le c_2 + c_4$. Multiplying by $B \ge 0$,
$$ B^2 \le B(c_2 + c_4) = B c_2 + B c_4 \le (\mathrm{wt}(a_1) + \mathrm{wt}(a_2)) + (\mathrm{wt}(a_3) + \mathrm{wt}(a_4)). $$
Reassociating the right-hand side completes the proof. $\;\square$

The structure is worth emphasizing: **the bound factors as $B^2$**, with one
factor of $B$ contributed by each outer round (active columns $\to$ active bytes)
and the product structure supplied by the super-box, which lower-bounds the
*sum* of the two outer rounds' active-column counts by $B$.

## 5. The AES specialization: at least 25 active S-boxes

**Theorem 5.1 (AES four-round bound; `aes_four_round_ge_25`).** Instantiate
Theorem 4.1 with the AES ShiftRows $\mathrm{aesShiftRows}$ and the AES branch
number $B = 5$ (MixColumns is MDS over $\mathrm{GF}(2^8)$). For any four-round
AES trail $a_1, a_2, a_3, a_4$ satisfying the round-1 and round-3 activity and
branch conditions and the super-box hypothesis $5 \le \mathrm{colActive}(a_2) + \mathrm{colActive}(a_4)$,
$$ 25 \;\le\; \mathrm{wt}(a_1) + \mathrm{wt}(a_2) + \mathrm{wt}(a_3) + \mathrm{wt}(a_4). $$

*Proof.* Apply Theorem 4.1 with $B = 5$; then $B^2 = 25$. $\;\square$

**Corollary 5.2 (Trail probability bound).** Since the AES S-box has maximal
differential probability $2^{-6}$, any four-round AES differential trail has
probability at most $(2^{-6})^{25} = 2^{-150}$. As $2^{-150} \ll 2^{-128}$, no
four-round differential trail is exploitable against the 128-bit cipher; the
identical count applies to linear trails with the linear branch number (Section
7, C3).

## 6. Tightness: the minimum is exactly 25

A lower bound alone does not pin down the minimum. We exhibit an explicit trail
attaining 25, certifying that the bound is sharp. We use $\alpha = \mathbb{Z}/2\mathbb{Z}$,
which faithfully represents activity patterns.

**Definition 6.1 (The $1\text{-}4\text{-}16\text{-}4$ trail).** Define four
states in $\mathrm{St}\,(\mathbb{Z}/2\mathbb{Z})\,4\,4$:

- $t_1\, i\, j = 1$ iff $i = 0 \wedge j = 0$ (a single active byte; weight 1);
- $t_2\, i\, j = 1$ iff $j = 0$ (one full active column; weight 4);
- $t_3\, i\, j = 1$ for all $i, j$ (the full state; weight 16);
- $t_4\, i\, j = 1$ iff $i = 0$ (one active byte per column; weight 4).

**Lemma 6.2 (Trail weight; `tight_trail_weight`).**
$$ \mathrm{wt}(t_1) + \mathrm{wt}(t_2) + \mathrm{wt}(t_3) + \mathrm{wt}(t_4) = 1 + 4 + 16 + 4 = 25. $$

*Proof.* By exhaustive evaluation over the finite state space. $\;\square$

**Theorem 6.3 (Tightness; `aes_four_round_tight`).** The trail
$t_1, t_2, t_3, t_4$ satisfies *all* hypotheses of Theorem 5.1: the round-1 and
round-3 activity equivalences, the round-1 and round-3 branch inequalities (each
with $B = 5$), the super-box branch $5 \le \mathrm{colActive}(t_2) + \mathrm{colActive}(t_4)$
(holding with equality, $1 + 4 = 5$), and $\mathrm{wt}(t_1) + \mathrm{wt}(t_2) + \mathrm{wt}(t_3) + \mathrm{wt}(t_4) = 25$.

*Proof.* Each conjunct is a closed statement over the finite state space and is
discharged by exhaustive evaluation. $\;\square$

**Corollary 6.4.** The minimum number of active S-boxes over four rounds of AES
is *exactly* 25: Theorem 5.1 shows $\ge 25$, and Theorem 6.3 exhibits a valid
trail with exactly 25. Moreover the bound is realized with the super-box branch
holding with equality, confirming that no slack remains in the wide-trail count.

## 6b. A worked example: tracing the bound on the tight trail

It is instructive to see every inequality of the proof fire on the explicit
trail of Definition 6.1, because the bound is realized with no slack at any step.

Consider round 1, the transition $t_1 \to t_2$. The input $t_1$ has a single
active byte at position $(0,0)$, so $\mathrm{wt}(t_1) = 1$. ShiftRows fixes row 0,
so $\mathrm{shiftRows}(\mathrm{aesShiftRows}, t_1)$ still has its single active
byte in column 0; thus exactly column 0 is active, matching $t_2$, which has its
full first column active and nothing else. The activity equivalence of Lemma 3.1
holds. For the one active column $j = 0$ we have
$\mathrm{colWeight}(\mathrm{shiftRows}(\mathrm{aesShiftRows}, t_1))\,0 = 1$ and
$\mathrm{colWeight}(t_2)\,0 = 4$, summing to $5 \ge B = 5$ — the branch number is
met with equality. The round-bound conclusion reads
$5 \cdot \mathrm{colActive}(t_2) = 5 \cdot 1 = 5 \le \mathrm{wt}(t_1) + \mathrm{wt}(t_2) = 1 + 4 = 5$,
again equality.

Now round 3, the transition $t_3 \to t_4$. Here $t_3$ is the full state
($\mathrm{wt}(t_3) = 16$), so after ShiftRows every column is still active; $t_4$
has exactly one active byte per column, so all four columns are active and the
activity equivalence holds. For each column $j$,
$\mathrm{colWeight}(\mathrm{shiftRows}(\mathrm{aesShiftRows}, t_3))\,j = 4$ and
$\mathrm{colWeight}(t_4)\,j = 1$, summing to $5 \ge B$. The round bound gives
$5 \cdot \mathrm{colActive}(t_4) = 5 \cdot 4 = 20 \le \mathrm{wt}(t_3) + \mathrm{wt}(t_4) = 16 + 4 = 20$,
once more with equality.

Finally the super-box: $\mathrm{colActive}(t_2) = 1$ and
$\mathrm{colActive}(t_4) = 4$, so $\mathrm{colActive}(t_2) + \mathrm{colActive}(t_4) = 5 = B$,
the super-box branch attained exactly. Chaining as in Theorem 4.1,
$$ 25 = 5 \cdot 5 = 5(1 + 4) = 5 \cdot 1 + 5 \cdot 4 = 5 + 20 = (1 + 4) + (16 + 4) = 25. $$
Every inequality in the entire argument is an equality on this trail. This is
the precise sense in which the wide-trail strategy is *optimal* for AES: there is
no wasted diffusion, and the canonical $1\text{-}4\text{-}16\text{-}4$ trail sits
exactly on the boundary of what the structure permits.

## 7. Discussion: the super-box hypothesis

The only ingredient not derived from first principles is the super-box branch
hypothesis `hsuper`: that for the two middle rounds,
$\mathrm{colActive}(a_2) + \mathrm{colActive}(a_4) \ge 5$. This is *true* — it is
exactly the statement that the AES super-box (the column-level map of two AES
rounds) is MDS with branch number 5 — but a fully formal proof requires MDS
coding theory over $\mathrm{GF}(2^8)$.

The intended proof factors the super-box as $\mathrm{MC} \circ \mathrm{SR} \circ \mathrm{MC}$
(MixColumns–ShiftRows–MixColumns). ShiftRows, being *diffusion-optimal*, ensures
each output super-column draws exactly one byte from each input super-column;
this lifts the bytewise MDS property of MixColumns to a super-column-level MDS
property at the level of $\mathrm{GF}(2^{32})$. The combinatorial half — that
ShiftRows disperses columns optimally — is already available; what remains is the
algebraic Singleton-bound-with-equality lemma for the MDS code. Isolating
`hsuper` as a hypothesis is therefore an honest factoring: every consequence
*above* it is proved with no gaps, and the remaining obligation is a single,
well-understood coding-theoretic fact.

## 8. Algorithms

The combinatorial content of the development is directly computable, which is
what makes the tightness claims checkable by evaluation. We summarize three
algorithms made explicit in the companion demos.

1. **Active-S-box counting.** Given a trail of states, compute
   $\mathrm{wt}$, $\mathrm{colWeight}$, and $\mathrm{colActive}$ for each, and
   sum the weights. Complexity $O(R \cdot r \cdot c)$ for $R$ rounds on $r \times c$
   states (here $O(4 \cdot 16) = O(64)$ per trail).

2. **Round-bound / super-box verification.** Given a four-round trail and a
   branch number $B$, check the round-1/round-3 activity and branch conditions
   and the super-box inequality; then certify $B^2 \le$ total weight. Complexity
   $O(r \cdot c)$ per round.

3. **S-box differential uniformity.** For a concrete byte S-box, build its
   difference-distribution table (DDT) and extract the maximal off-origin entry,
   confirming $p_{\max} = 4/256 = 2^{-6}$ for the AES inversion S-box. Complexity
   $O(2^{2m})$ for $m$-bit S-boxes; $O(2^{16})$ for AES.

## 9. Applications

- **Provable resistance to differential/linear cryptanalysis.** The 25-S-box
  count is the quantitative backbone of AES's security argument and appears in
  the official design rationale.
- **Cipher design with safety certificates.** The generic $B^2$ bound is a
  recipe: pick a diffusion-optimal byte permutation and a branch-$B$ mixing
  layer, and four rounds inherit a $B^2$ guarantee. This principle underlies many
  modern SPN ciphers, hash functions, and authenticated-encryption schemes.
- **Automated trail-search bounds.** The counting framework gives provable floors
  that complement MILP/SAT-based trail search, certifying that no better trail
  exists below a threshold.

## 10. Future work

See the dedicated future-directions discussion for the full program. Briefly:
(C1) discharge `hsuper` via a formal MDS-code lemma over $\mathrm{GF}(2^8)$;
(C2) prove the AES inversion S-box has differential uniformity exactly 4;
(C3) instantiate the same engine for *linear* trails using the linear branch
number; and (C4) generalize the $B^2$ bound to arbitrary wide-trail SPNs and
characterize when it is tight.

## 11. Conclusion

We have given a self-contained, machine-checked development of the wide-trail
strategy's headline result: four rounds of AES activate at least 25 S-boxes, and
exactly 25 is achievable. The proof is structurally transparent — a generic
$B^2$ bound built from a round bound and a super-box branch property, specialized
to $B = 5$ — and the tightness witness is verified by exhaustive evaluation. The
result turns a celebrated heuristic of cipher design into a formally certified
theorem, with the one remaining algebraic ingredient cleanly isolated for a
follow-up.
