# Twenty-Five Locks: How AES Mathematically Guarantees Its Own Strength

Every time you visit a website whose address begins with `https`, send a
message on a chat app, or unlock a phone, a cipher called **AES** — the
Advanced Encryption Standard — is almost certainly scrambling your data.
AES has guarded the world's secrets since 2001, and despite two decades of
relentless attack by the best cryptographers on Earth, it has never been
broken in practice. That is not luck. It is mathematics. And at the heart of
that mathematics lies a single, beautiful number: **25**.

This is the story of why that number means AES is safe, and how the claim can
be turned into a theorem so precise that a machine can check it.

## The two great attacks on block ciphers

To understand why 25 matters, you first have to understand what would-be
codebreakers actually try to do.

A block cipher like AES takes a 16-byte block of data and a secret key, and
churns them together through several **rounds** of scrambling. Each round
mixes the bits so thoroughly that the output looks like random noise. The
question every cryptographer asks is: *does it really look random, or is there
a faint statistical fingerprint an attacker could exploit?*

Two attacks dominate the field, both discovered around 1990:

- **Differential cryptanalysis** watches how *differences* propagate. Feed the
  cipher two inputs that differ in a known pattern, and look at how their
  outputs differ. If certain input differences lead to certain output
  differences far more often than pure chance would allow, the cipher leaks
  information. The attacker chases a *differential trail* — a round-by-round
  story of how a difference threads its way through the cipher.

- **Linear cryptanalysis** instead looks for linear equations among input bits,
  output bits, and key bits that hold slightly more often than half the time.
  Again the attacker chases a trail, this time of *linear masks*.

Both attacks share the same Achilles' heel: they only work if some trail through
the cipher has a probability (or correlation) that is not vanishingly small. If
*every* trail is astronomically unlikely, both attacks collapse. The designers
of AES, Joan Daemen and Vincent Rijmen, set out to *prove* that this is the
case. Their tool was a design philosophy they called the **wide-trail
strategy**.

## The S-box: a deliberately confusing ingredient

Each AES round begins by passing all 16 bytes through a fixed lookup table
called the **S-box**. The S-box is the cipher's one genuinely nonlinear
ingredient — it is what makes AES more than a tangle of solvable linear
equations.

The crucial property of the S-box is how it handles differences. Suppose two
inputs differ by a fixed amount $a$ (a byte XOR difference, written
$a \neq 0$). What is the chance that their outputs differ by some chosen amount
$b$? For the AES S-box, this probability is *never larger than* $2^{-6}$. In the
language of cryptanalysis, the S-box has **differential uniformity 4**: out of
the 256 possible input pairs with a given difference, at most 4 produce any
particular output difference, and $4/256 = 2^{-6}$.

That $2^{-6}$ is a small number, but it is not small enough on its own. A trail
through AES touches many S-boxes; the trail's total probability is roughly the
*product* of the probabilities at every S-box it activates. So the security
question becomes purely a counting problem:

> **How many S-boxes must any trail activate?**

An S-box is **active** in a trail if the difference passing through it is
nonzero — if it actually does some work. The more active S-boxes a trail is
forced to touch, the more factors of $2^{-6}$ pile up, and the more hopeless the
attack becomes. If a trail must activate $n$ S-boxes, its probability is at most
$(2^{-6})^n = 2^{-6n}$.

AES uses a 128-bit key, so any attack needs a trail with probability above
roughly $2^{-128}$ to beat brute force. The magic threshold is therefore
$6n \ge 128$, i.e. $n \ge 22$. If we can guarantee that every trail activates at
least 25 S-boxes, then every trail has probability at most
$2^{-150}$ — comfortably below $2^{-128}$. The cipher is safe by a wide margin.

So the entire security argument reduces to one combinatorial claim about four
rounds of AES.

## The geometry of a round

To count active S-boxes, picture the AES state not as 16 bytes in a row but as
a **$4 \times 4$ grid** of bytes — four rows, four columns. Three operations
move the differences around this grid:

- **SubBytes** applies the S-box to each cell. It can turn a nonzero byte into
  another nonzero byte, but it never creates a difference where there was none
  or destroys one that was there. So *it does not change the pattern of which
  cells are active* — it only determines the probability cost.

- **ShiftRows** cyclically rotates each row by a different amount: row 0 not at
  all, row 1 by one, row 2 by two, row 3 by three. This is a pure permutation of
  positions. Its job is **diffusion across columns**: it guarantees that the
  four bytes of any single column get scattered into four *different* columns.

- **MixColumns** treats each column of four bytes as a short vector and
  multiplies it by a fixed matrix over the finite field $\mathrm{GF}(2^8)$. This
  is where the deep magic lives.

The MixColumns matrix is chosen to be **MDS** — *maximum distance separable*. In
coding-theory terms, the map from a column to its image is a code that meets the
*Singleton bound* with equality. The practical consequence is a single,
powerful inequality. Define the **branch number** $B$ of MixColumns as the
smallest possible value of

$$ \text{(active bytes in)} + \text{(active bytes out)} $$

taken over all nonzero column inputs. For an MDS matrix on 4-byte columns,
$B = 5$. In words:

> **If a column entering MixColumns has even one nonzero byte, then the input
> and output together contain at least 5 nonzero bytes.**

You cannot have a column with one active byte in and one active byte out; the
mixing forces at least four on one side or a healthy split. This is the engine
of diffusion, and the number 5 is about to become 25.

## From 5 to 25: the wide-trail count

Here is the elegant heart of the wide-trail strategy. We track a four-round
trail through states $a_1 \to a_2 \to a_3 \to a_4$ and prove that the **total**
number of active S-boxes,

$$ \mathrm{wt}(a_1) + \mathrm{wt}(a_2) + \mathrm{wt}(a_3) + \mathrm{wt}(a_4), $$

is at least $5^2 = 25$. (Here $\mathrm{wt}$ counts the nonzero bytes in a
state.) The proof is a chain of three observations.

**Observation 1 — a single round multiplies by the branch number.** Consider
one round acting on a state. ShiftRows scatters each column, then MixColumns
mixes. Combine the branch-number inequality with the scattering, and you get
what we call the *round bound*: for each active column, the round contributes at
least $B$ active bytes. Summing over columns,

$$ B \cdot (\text{number of active output columns}) \le (\text{active bytes across the round}). $$

Apply this to round 1 and to round 3. Each gives a factor of $B$.

**Observation 2 — the two middle rounds form a "super-box".** Rounds 2 and 3,
viewed together, can be regrouped into four independent **super-boxes**, each
acting on a *super-column* of 32 bits. Daemen and Rijmen's key insight is that
this super-box is *itself* MDS, now at the level of whole columns. Its branch
number is again $5$:

$$ (\text{active columns of } a_2) + (\text{active columns of } a_4) \ge 5. $$

A nonzero pattern of input columns and output columns must, together, light up
at least five columns.

**Observation 3 — multiply it all together.** Now simply chain the pieces. Let
$c_2$ and $c_4$ be the numbers of active columns in $a_2$ and $a_4$. The
super-box gives $c_2 + c_4 \ge 5$. The round bound applied to rounds 1 and 3
gives $5 c_2 \le \mathrm{wt}(a_1) + \mathrm{wt}(a_2)$ and
$5 c_4 \le \mathrm{wt}(a_3) + \mathrm{wt}(a_4)$. Therefore

$$ 25 = 5 \cdot 5 \le 5 (c_2 + c_4) = 5 c_2 + 5 c_4 \le \mathrm{wt}(a_1) + \mathrm{wt}(a_2) + \mathrm{wt}(a_3) + \mathrm{wt}(a_4). $$

Twenty-five. The branch number squared. Every four-round trail of AES must
activate at least twenty-five S-boxes, and so has probability at most
$(2^{-6})^{25} = 2^{-150}$.

This is the *generic* statement, and it is worth pausing on its shape. Nothing
in the argument is special to the number 5 or to AES's particular tables. Any
substitution-permutation cipher built from a diffusion-optimal byte
permutation and a branch-$B$ mixing layer earns a four-round guarantee of
$B^2$ active S-boxes. The number 25 is simply what you get when the engine is
tuned to $B = 5$.

## Is 25 the best possible? Yes, exactly.

A lower bound is only half a story. Maybe the *true* minimum is 30, or 40, and
our argument was merely weak. To nail down that 25 is the honest answer, we must
exhibit an actual trail that activates *exactly* 25 S-boxes. That trail is a
classic, and it follows a memorable pattern: **1, 4, 16, 4**.

- **Round 1 input $a_1$:** a single active byte — say the top-left corner.
  Weight $1$.
- **After round 1 ($a_2$):** that single byte, scattered and mixed, fills one
  entire column. Weight $4$. (This is the branch number in action: one byte in,
  four out, totalling five.)
- **After round 2 ($a_3$):** the full column spreads — via ShiftRows into four
  columns, then via MixColumns into every cell — to light up the whole state.
  Weight $16$.
- **After round 3 ($a_4$):** the pattern contracts back down to one active byte
  per column. Weight $4$.

Add them up: $1 + 4 + 16 + 4 = 25$. Every constraint of the lower-bound theorem
is satisfied, and the super-box branch holds with *equality* ($1 + 4 = 5$). So
25 is not just a floor; it is the floor *and* the ground beneath someone's feet.
The minimum number of active S-boxes over four rounds of AES is **exactly 25**.

This tightness is what makes the result so satisfying. The wide-trail strategy
does not merely succeed — it succeeds *optimally*. AES extracts the maximum
possible diffusion from its four-round structure, with no slack wasted.

## What it means to *prove* this

Cryptographers have believed the 25-S-box bound since the 1990s; it appears in
the original AES design documents and in every textbook on block ciphers. What
is newer is the ability to state and verify the argument with the full rigor of
formal mathematics, leaving no room for a hidden gap.

The argument above was reconstructed as a precise theorem. The states are
honest $4 \times 4$ grids over a finite field; ShiftRows is the genuine AES
permutation; the branch number, the round bound, the super-box property, and the
final multiplication are all stated exactly. The generic theorem proves the
$B^2$ bound from the round bound and the super-box hypothesis; specializing to
$B = 5$ delivers the headline 25; and the explicit $1\text{-}4\text{-}16\text{-}4$
trail — built cell by cell and checked by exhaustive evaluation — certifies that
25 is tight.

One ingredient is honestly flagged as an assumption rather than re-derived from
scratch: the super-box branch property, that the two middle rounds together
behave as an MDS code with branch 5. This is a true fact — it follows from the
MDS property of MixColumns combined with the optimal scattering of ShiftRows —
but a fully formal proof requires the theory of MDS codes over $\mathrm{GF}(2^8)$
and the Singleton bound met with equality. Everything that rests *on top* of it
is proved with no gaps, and closing this last assumption is the natural next
chapter.

## Why this picture matters beyond AES

The story of 25 is really a story about a *design principle that comes with a
proof attached*. For most of history, cipher design was an arms race of
intuition: a designer would build something clever, and the world would attack
it until either it broke or everyone got tired. The wide-trail strategy changed
the game. It lets a designer *quantify* resistance to the two most powerful known
attacks before the cipher ever ships, by reducing security to a clean counting
problem about branch numbers.

That same principle now guides a whole generation of ciphers and hash functions
— lightweight ciphers for tiny devices, authenticated-encryption schemes, even
some post-quantum constructions. Choose a permutation that scatters well, choose
a mixing layer with a large branch number, and the multiplication
$B \times B$ does the rest. The wide-trail strategy turned a dark art into
something closer to engineering with a safety certificate.

And the certificate is exactly the kind of thing that should be machine-checked.
When a number like 25 stands between your bank password and an adversary, it is
worth knowing — with the certainty of a verified proof — that the number is not
24, and that the strategy really does deliver what it promises. Twenty-five
locks, each one provably necessary. That is how mathematics keeps a secret.
