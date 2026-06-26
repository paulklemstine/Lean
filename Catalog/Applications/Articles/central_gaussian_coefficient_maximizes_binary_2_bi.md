# The Most Crowded Room in the House of Words

Imagine you are handed a long strip of paper marked off into $n$ little boxes,
and a bag containing exactly $k$ black beads and $n-k$ white beads. You drop the
beads into the boxes, one per box, in some order. The result is a *binary word*:
a string of blacks and whites, ones and zeros. There are $\binom{n}{k}$ ways to do
this — a number that grows astronomically as the strip gets longer. With just
$30$ boxes and $15$ beads of each color, there are more than $150$ million
arrangements.

Now ask a deceptively simple question. We are going to sort all of these
arrangements into bins, grouping together the ones that are "the same" in a
precise combinatorial sense. Some bins will end up nearly empty; others will be
packed. **Which bin is the most crowded, and exactly how crowded does it get?**

The answer turns out to be beautiful, exact, and connected to a chain of ideas
stretching from nineteenth-century algebra to the statistical physics of crystals
and the inner workings of quantum groups. This article tells that story.

## When are two words "the same"?

To group words into bins we need a notion of sameness. The one we use comes from
a corner of combinatorics called *binomial equivalence*, introduced by Michel
Rigo and Pavel Salimov. The idea is wonderfully tactile.

Take a word and start counting **patterns scattered inside it**. How many times
does a single black bead appear? That is just $k$, the number of ones. How many
whites? That is $n-k$. These counts are the same for every arrangement with the
same beads, so they tell us nothing new.

The interesting patterns are the ones of length two. Pick two positions, a left
one and a right one. If the left bead is black and the right bead is white, you
have found a scattered copy of the pattern "$10$" — a black-before-white. Count
*all* such pairs in your word. This number is the word's **inversion number**.
(There is a twin statistic, the *co-inversion number*, that counts white-before-black
pairs, the pattern "$01$".)

Two binary words are declared **2-binomially equivalent** when they agree on
*every* count of length-one and length-two scattered patterns. For binary words
this collapses into something marvelously concrete: two words are equivalent
exactly when they have

* the same length $n$,
* the same number of ones $k$, and
* the same inversion number $i$.

That is the whole story. A 2-binomial class is pinned down by just three numbers,
$(n, k, i)$. Every bin in our sorting is labeled by such a triple, and the number
of words in that bin is what we'll call the **class size**, written
$\mathrm{classSize}(n, k, i)$.

So our headline question becomes: *for fixed $n$ and $k$, which inversion number
$i$ gives the biggest class, and how big is it?*

## A first look at the bins

Let's get our hands dirty with a small example. Take words of length $4$ with
exactly $2$ ones. There are $\binom{4}{2} = 6$ of them. Writing each as a string
of bits and recording its inversion number (black-before-white pairs):

| word | inversions |
|------|:----------:|
| `0011` | 0 |
| `0101` | 1 |
| `0110` | 2 |
| `1001` | 2 |
| `1010` | 3 |
| `1100` | 4 |

Sorting into bins by inversion number, the class sizes are

$$1,\ 1,\ 2,\ 1,\ 1.$$

There is a single word with $0$ inversions (everything sorted whites-first), a
single word with the maximum of $4$ inversions (everything blacks-first), and a
fat bin of *two* words in the middle, at $2$ inversions. The most crowded room is
dead center.

Push a little further. Words of length $6$ with $3$ ones give the row

$$1,\ 1,\ 2,\ 3,\ 3,\ 3,\ 3,\ 2,\ 1,\ 1,$$

ten numbers summing to $\binom{6}{3} = 20$. Again the sequence rises from the
edges to a plateau in the middle and falls back down, perfectly symmetric. These
two features — **the peak in the center** and the **mirror symmetry** — are not
accidents of small cases. They are theorems, and they have names.

## The hidden polynomial

Here is where the story takes a turn that would have delighted a Victorian
algebraist. Those rows of numbers are not random. They are the coefficients of a
famous family of polynomials called the **Gaussian binomial coefficients**, also
known as $q$-binomial coefficients and written $\genfrac{[}{]}{0pt}{}{n}{k}_q$.

The ordinary binomial coefficient $\binom{n}{k}$ counts subsets of size $k$. The
Gaussian binomial coefficient refines that count by tracking *how spread out* each
subset is, packaging the information into a polynomial in a variable $q$. For
length $4$ and $2$ ones,

$$\genfrac{[}{]}{0pt}{}{4}{2}_q = 1 + q + 2q^2 + q^3 + q^4,$$

and look — its coefficients are exactly the bin sizes $1,1,2,1,1$ we found by
hand. This is no coincidence. It is a classical result going back to **Percy
MacMahon**, the great combinatorialist (and, fittingly, a former artillery
officer who counted things for a living). MacMahon's theorem says:

> The number of binary words of length $n$ with $k$ ones and inversion number $i$
> is precisely the coefficient of $q^i$ in the Gaussian binomial coefficient
> $\genfrac{[}{]}{0pt}{}{n}{k}_q$.

In our notation, $\mathrm{classSize}(n, k, i)$ *is* that coefficient. The
combinatorial question about crowded bins and the algebraic question about
polynomial coefficients are one and the same question wearing two costumes.

This dictionary is powerful because each side knows things the other does not.
From the word side, certain facts are obvious. From the polynomial side, deep
machinery becomes available. The art is in playing them against each other.

## Three facts you can prove with your hands

Several of the features we noticed have clean, hands-on explanations — and each
one has been verified as a formal mathematical theorem.

**The bins always sum to a binomial.** Every arrangement of $k$ ones among $n$
boxes lands in exactly one bin, so adding up all the bin sizes must recover the
total number of arrangements:

$$\sum_{i=0}^{k(n-k)} \mathrm{classSize}(n, k, i) = \binom{n}{k}.$$

For length $5$ with $2$ ones this says $1+1+2+2+2+1+1 = 10 = \binom{5}{2}$. It is
the statement that we have, in fact, sorted *everything* and lost nothing.

**The inversions never exceed $k(n-k)$.** Each black-before-white pair needs one
black bead and one white bead, and there are only $k$ blacks and $n-k$ whites to
work with, so the inversion number can never be larger than $k(n-k)$. That
maximum is achieved exactly once — by the word with all blacks crammed to the
left. Beyond it, every bin is empty.

**The picture is a perfect mirror.** Here is the prettiest argument. Take any
word and **reverse it**, reading right to left. A black-before-white pair becomes
a white-before-black pair, and vice versa: reversal swaps inversions with
co-inversions. Since a word's inversions and co-inversions always add up to the
full $k(n-k)$ mixed pairs, a word with $i$ inversions reverses into a word with
$k(n-k) - i$ inversions. Reversal is its own undo, so it sets up a perfect
pairing between the bin at $i$ and the bin at $k(n-k) - i$. They must be the same
size:

$$\mathrm{classSize}(n, k, i) = \mathrm{classSize}\bigl(n, k,\ k(n-k) - i\bigr).$$

This is the **palindromic symmetry**, and it instantly tells us that *if* there
is a single peak, it must sit at the center, the value $k(n-k)/2$.

It also has a probabilistic punchline. If you pick one of the $\binom{n}{k}$ words
uniformly at random, the symmetry forces the **average inversion number** to land
exactly on the center: the expected number of black-before-white pairs is
$k(n-k)/2$, no calculation required beyond the mirror.

## The crown jewel: the center really is the maximum

Symmetry says the center is the natural candidate for the most crowded bin. But
symmetry alone does not prove the candidate wins. A symmetric mountain range
could in principle have two matching peaks flanking a central valley. To know the
center truly holds the record, we need the sequence to climb steadily to the
middle and then descend — a property mathematicians call **unimodality**.

For Gaussian binomial coefficients, unimodality is famous, and famously hard. It
was first proved by **James Joseph Sylvester** in 1878, and his proof was a
tour de force using the *invariant theory* of binary forms — heavy nineteenth-century
algebraic artillery. For over a century, no genuinely elementary proof existed.
The modern viewpoint connects it to the **hard Lefschetz theorem** from algebraic
geometry, and to the representation theory of the Lie algebra $\mathfrak{sl}_2$,
where the rising-and-falling shape of the coefficients becomes a shadow of how a
symmetry operator acts on a vector space. The first truly elementary,
combinatorial proof had to wait until **Kathleen O'Hara** in 1990, who built an
explicit, intricate construction by hand.

In other words: the innocent observation that the middle bin is the most crowded
sits atop one of the deeper results in combinatorics, with roots in algebra,
geometry, and the mathematics of quantum symmetry.

Because the general theorem is so deep, the formal development here takes a
careful, honest stance. It proves the easy structural facts — the total, the
ceiling, the mirror symmetry, the mean — completely and in full generality. For
the headline claim that **the central inversion number gives the global maximum**,
it does something a paper-and-pencil mathematician cannot: it asks a computer to
*check the claim rigorously, with the same certainty as a proof*, for every length
up to $8$. For each such $n$ and each number of ones $k$, the machine confirms
that the central bin $\mathrm{classSize}(n, k, \lfloor k(n-k)/2 \rfloor)$ is at
least as large as every other bin. No floating-point guesswork, no sampling — a
complete, exhaustive, kernel-verified check.

This is a recurring theme in modern mathematics: state the deep general principle
as a precise conjecture, prove everything you honestly can, and pin down the rest
with exhaustive certified computation rather than hand-waving.

## Why anyone should care

This might look like a self-contained puzzle about beads and strips, but the same
numbers surface all over science.

**Physics and crystals.** The inversion number is, in disguise, an *energy*. Think
of the ones and zeros as two types of atoms on a one-dimensional lattice, where
each black-before-white pair contributes a unit of energy. Then the bin sizes are
exactly the *degeneracies* — how many microscopic configurations share a given
energy — and the polynomial $\genfrac{[}{]}{0pt}{}{n}{k}_q$ is a **partition
function** with $q$ playing the role of a Boltzmann weight. The fact that the
middle energy level is the most degenerate is a combinatorial fingerprint of why
systems pile up near their average energy.

**Probability and concentration.** The same statistic governs how the inversion
count of a random word fluctuates. The mirror symmetry pins the average at
$k(n-k)/2$; a second, finer analysis shows the spread is tightly controlled, with
variance $k(n-k)(n+1)/12$. The distribution is sharply peaked around its center —
a discrete cousin of the bell curve, and a concrete instance of the
*concentration of measure* that underlies so much of modern probability and data
science.

**Algebra and quantum groups.** The variable $q$ is not just bookkeeping. Setting
$q = 1$ collapses the Gaussian binomial back to the ordinary $\binom{n}{k}$, but
keeping $q$ alive opens the door to **$q$-analogues** — quantum versions of
classical objects that pervade the theory of quantum groups, the combinatorics of
flag varieties, and even the counting of subspaces of vector spaces over finite
fields (where $\genfrac{[}{]}{0pt}{}{n}{k}_q$ literally counts $k$-dimensional
subspaces of an $n$-dimensional space over the field with $q$ elements).

**Partitions in a box.** There is a final, charming reinterpretation. The bin at
inversion number $i$ has exactly as many words as there are ways to write $i$ as a
sum of at most $k$ whole numbers, none larger than $n-k$ — the *partitions that
fit inside a $k \times (n-k)$ box*. The most crowded bin is then the partition
size achieved by the most boxes-worth of diagrams, and unimodality becomes a
statement about how partition counts swell and shrink as you change the target sum.

## The shape of certainty

What makes this story satisfying is not just that the center wins, but *how* we
come to believe it. We start with a concrete game — beads in boxes — and a simple
question. We discover, by direct counting, two striking regularities: a mirror and
a peak. We give the mirror a one-line proof you can do in your head (just reverse
the word). And we trace the peak back through a century and a half of mathematics,
all the way to invariant theory and quantum symmetry, honestly admitting which
parts are elementary and which are deep.

Then, for the deep part, we do not bluff. We let a machine certify the claim,
exhaustively and incorruptibly, on every case it can reach, while marking the
fully general statement as the next mountain to climb. That blend — elementary
arguments where they suffice, certified computation where they don't, and a clear
map of what remains — is what mathematical honesty looks like in the twenty-first
century.

The most crowded room in the house of words, it turns out, is exactly the one in
the middle. And knowing *why* takes us on a tour of some of the most beautiful
mathematics there is.
