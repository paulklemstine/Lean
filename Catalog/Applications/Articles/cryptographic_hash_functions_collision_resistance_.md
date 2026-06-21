# The Hidden Arithmetic of Broken Hashes

## When two doors open with the same key

Imagine a vault with millions of doors, and a magic machine that turns any
phrase you whisper into a single key. Say "open sesame" and out comes a key.
Say "the quick brown fox" and out comes a different key. The machine is fast,
it is deterministic, and — this is the whole point — it is supposed to be
*impossible* to find two different phrases that produce the *same* key.

That machine is a **cryptographic hash function**. Its keys are the
fingerprints that protect your downloads, your passwords, your bank transfers,
and the entire blockchain economy. The moment someone finds two different
inputs with the same fingerprint — a **collision** — a crack appears in the
foundation. Forged certificates, swapped contracts, and counterfeit files all
become possible.

So the natural question is: *why* should collisions be hard to find? We cannot
simply hope they are rare. Hash designers want a guarantee with a spine of
steel: "if you could break my hash, then you could solve a problem that
humanity has been failing to solve for centuries." This is the deep idea
behind modern cryptography — **reductions**. You do not prove your lock is
unbreakable. You prove that breaking your lock is *at least as hard* as some
famous, stubborn problem.

This article tells the story of three linked ideas that make this slogan
precise and, remarkably, completely rigorous:

1. **The Merkle–Damgård construction** — the assembly line that turns a small,
   fixed-size "compression function" into a hash that eats messages of *any*
   length.
2. **A preservation theorem** — a proof that this assembly line never
   *introduces* new weaknesses: any collision in the big hash can be
   mechanically converted into a collision in the small building block.
3. **A bridge to a hard problem** — a concrete, fully worked example where
   "find a hash collision" becomes, literally, "factor a number in two
   different ways."

By the end, you will see a single number, $210$, quietly break a hash — and
understand exactly why.

---

## Part I: How to hash a message of any length

Real messages are not all the same size. A tweet, a movie, and a legal
contract all need fingerprints, but a hash machine has fixed-size gears
inside. The standard trick — used in SHA-256, MD5, SHA-1, and almost every
hash you have ever relied on — is the **Merkle–Damgård construction**, named
after Ralph Merkle and Ivan Damgård, who independently discovered it in 1989.

The idea is an assembly line. Start with a small machine called a
**compression function**:

$$f : \text{State} \times \text{Block} \to \text{State}.$$

Think of it as a worker who holds a running summary (the *state*, or *chaining
value*) and reads one fixed-size *block* of the message at a time. After
reading a block, the worker updates the summary. We seed the worker with a
fixed starting summary called the **initialization vector**, $iv$. Then we feed
blocks in one by one:

$$\text{state}_0 = iv, \qquad \text{state}_{i+1} = f(\text{state}_i,\ \text{block}_i).$$

The final summary is the hash. In the language of functional programming this
is a *left fold*, and that is exactly how we define it:

$$\mathrm{mdHash}(f, iv, [b_0, b_1, \dots, b_{n-1}]) = f(\cdots f(f(iv, b_0), b_1)\cdots, b_{n-1}).$$

A few facts about this assembly line are so basic they barely need proof, yet
they are the load-bearing beams of everything that follows. Hashing the empty
message returns the seed untouched:

$$\mathrm{mdHash}(f, iv, [\,]) = iv.$$

Appending one more block $b$ to a message just runs the worker one more step:

$$\mathrm{mdHash}(f, iv, \ell \mathbin{+\!\!+} [b]) = f\big(\mathrm{mdHash}(f, iv, \ell),\ b\big).$$

And gluing two messages together is the same as restarting the second from
wherever the first left off:

$$\mathrm{mdHash}(f, iv, a \mathbin{+\!\!+} b) = \mathrm{mdHash}\big(f,\ \mathrm{mdHash}(f, iv, a),\ b\big).$$

That last "composition" property is the secret to the whole construction. It
says the hash has *no memory* beyond its current chaining value — and that, as
we will see, is exactly what lets us trap a collision.

---

## Part II: Collisions cannot hide in the assembly line

Now the central question. We built a big hash out of a small compression
function. What if the assembly process itself *creates* weaknesses — collisions
in the big hash that do not correspond to any flaw in the small part? If that
were possible, securing the building block would be useless.

The good news is a theorem that rules this out completely. First, what does it
mean for the small building block to have a flaw? A **compression collision**
is two genuinely different inputs that the worker cannot tell apart:

$$(s, b) \neq (s', b') \quad\text{but}\quad f(s, b) = f(s', b').$$

The preservation theorem then says:

> **Merkle–Damgård collision extraction.** Suppose two *different* messages of
> the *same length* hash to the same value:
> $$m_1 \neq m_2, \quad |m_1| = |m_2|, \quad \mathrm{mdHash}(f, iv, m_1) = \mathrm{mdHash}(f, iv, m_2).$$
> Then one can *explicitly construct* a compression collision of $f$.

This is not an existence statement that merely promises a collision is "out
there." It is a recipe. Hand it any collision in the full hash and it hands
back a specific pair $(s, b) \neq (s', b')$ with $f(s, b) = f(s', b')$.

The argument is a beautiful little proof by working *backwards* from the end of
the message. Compare the two messages block by block, starting from the last
block. Write $m_1 = p_1 \mathbin{+\!\!+} [b_1]$ and $m_2 = p_2 \mathbin{+\!\!+} [b_2]$.
By the append rule, the final hashes are

$$f\big(\mathrm{mdHash}(f, iv, p_1),\ b_1\big) \quad\text{and}\quad f\big(\mathrm{mdHash}(f, iv, p_2),\ b_2\big),$$

and these are assumed equal. Now look at the two inputs to that last
application of $f$. They are either *different* or *the same*:

- If the chaining values differ or the last blocks differ — that is,
  $(\mathrm{mdHash}(f,iv,p_1), b_1) \neq (\mathrm{mdHash}(f,iv,p_2), b_2)$ — then
  we have caught a compression collision *right there*. Done.
- If they are identical, then the final blocks are equal *and* the two prefixes
  hashed to the same chaining value. But the prefixes $p_1$ and $p_2$ are
  shorter, still of equal length, and (since the originals differed but the
  last blocks matched) still different from each other. So we repeat the
  argument on the shorter messages.

Each step either finds the collision or shrinks the problem. Because messages
are finite, the recursion cannot continue forever; it must terminate by
catching a genuine compression collision. And the base case is airtight: two
*empty* messages are necessarily equal, which contradicts the assumption that
our messages differ — so we never "run out of blocks" without a collision in
hand.

### Why "same length" is not a footnote

The theorem carefully insists the two messages have the *same length*. This is
not laziness — it is the precise boundary of truth. Without it, the
construction can collide for a boring reason that has nothing to do with the
compression function's strength.

Consider the multiplicative toy hash we will meet in Part III, where
$f(s, b) = s \cdot b$ starting from $iv = 1$. The one-block message $[6]$ and
the two-block message $[2, 3]$ both hash to $6$ — but $[6] \neq [2,3]$ and they
have *different lengths*. This is a "length-extension"-style collision: it
exploits the fact that messages of different sizes can sneak into the same
chaining value. It does **not** come from any failure of $f$ to distinguish its
inputs. That is exactly why real-world hashes perform **length padding** (the
"strengthening" in *Merkle–Damgård strengthening*): they append the message
length as a final block, which forces any colliding messages to agree on length
and converts the leftover cases back into honest compression collisions.

### Collisions always exist — finding them is the hard part

There is a humbling companion fact, a pigeonhole observation. If the compression
function maps a large input space into a smaller state space — and compression
*by definition* shrinks — then collisions must exist. There are simply more
pigeons (inputs) than holes (outputs). So collision *resistance* can never mean
"no collisions exist." It can only mean "collisions are computationally
infeasible to *find*." The extraction theorem respects this distinction
exactly: it never claims collisions are rare, only that *if* you locate one in
the big hash, you have effectively located one in the small part. Security is
about searching, not existence.

---

## Part III: Where a hash meets a hard problem

We now have an assembly line that faithfully passes weaknesses down to its
building block. But that only shifts the question: why is the *building block*
hard to break? For a satisfying answer, we want to anchor it to a problem
everyone already believes is hard. The cleanest illustration uses one of the
oldest hard problems in mathematics: **factoring integers**.

Choose the simplest possible compression function — multiplication:

$$\mathrm{mulCompress}(s, b) = s \cdot b.$$

The worker's "summary" is just a running product. Seed it with $iv = 1$, feed
it a list of numbers, and the Merkle–Damgård hash is exactly their product:

$$\mathrm{mdHash}(\mathrm{mulCompress}, 1, [b_0, \dots, b_{n-1}]) = b_0 \cdot b_1 \cdots b_{n-1}.$$

Now, what is a collision for *this* hash? Two different lists of numbers with
the same product. And two different factorizations of the same number is
precisely a **non-unique factorization** — the failure of a set of numbers to
factor in only one way.

Here is where a tidy piece of number theory enters. Call a quadruple
$(a, b, c, d)$ a **product collision** in a set $S$ if all four belong to $S$,
all are at least $2$, the products match,

$$a \cdot b = c \cdot d,$$

and yet the *pairs are genuinely different* as unordered collections,
$\{a, b\} \neq \{c, d\}$. This is the algebraic shadow of a hash collision: two
different "inputs" (factor pairs) with the same "output" (product).

The bridge theorem says these two notions are the *same thing*:

> **From algebraic hardness to a compression collision.** If a set $S$ has a
> product collision, then the multiplicative compression function
> $\mathrm{mulCompress}$ has a compression collision.

The proof is almost a tautology once you see it. A product collision gives
$a \cdot b = c \cdot d$ with $\{a,b\} \neq \{c,d\}$. If the ordered pairs
$(a,b)$ and $(c,d)$ were equal, the unordered pairs would be equal too — so the
ordered pairs must differ. That is exactly the inequality
$(a, b) \neq (c, d)$ together with $\mathrm{mulCompress}(a,b) = \mathrm{mulCompress}(c,d)$.
A compression collision, served on a plate.

Chaining this with the extraction theorem of Part II gives the headline:

> **Algebraic hardness $\Rightarrow$ hash collision.** If two different lists of
> numbers of the same length have the same product, then the iterated
> multiplicative hash has a collision — and from it we can extract a
> compression collision.

### The number 210 breaks a hash

Abstractions deserve a concrete victim. Consider the four numbers
$\{6, 10, 21, 35\}$. They are carefully chosen: no product of two of them lands
back inside the set, so by a naive test they look "multiplicatively
independent." And yet:

$$6 \times 35 = 210 = 10 \times 21.$$

Two different pairs, one product. As unordered collections,
$\{6, 35\} \neq \{10, 21\}$ — these are genuinely different factor pairs. Now
feed them to the multiplicative hash as two length-2 messages:

$$\mathrm{mdHash}(\mathrm{mulCompress}, 1, [6, 35]) = 210 = \mathrm{mdHash}(\mathrm{mulCompress}, 1, [10, 21]).$$

The messages $[6, 35]$ and $[10, 21]$ are different, have equal length, and
collide. Running the extraction recipe of Part II on this collision pops out an
explicit collision of the multiplication map. The entire pipeline — from a
number-theoretic curiosity about $210$ to a full Merkle–Damgård hash collision —
executes end to end on this single example.

Of course, multiplication is a *terrible* real hash; you can factor small
numbers in your head. But that is the point of a clean illustration: it makes
the equivalence *visible*. Finding a collision is finding a second
factorization. Make the numbers astronomically large — products of secret
primes, as in RSA — and "find a second factorization" becomes the factoring
problem that has resisted the world's best mathematicians and computers. The
toy and the titan run on the same logic.

---

## The big picture: a chain of "at least as hard as"

Step back and admire the architecture. We have built a chain of reductions,
each link a rigorous theorem:

$$\textbf{hard arithmetic} \;\Rightarrow\; \textbf{compression collision} \;\Rightarrow\; \textbf{full hash collision},$$

and, read in reverse, the security guarantee we wanted:

$$\textbf{the hash is unbroken} \;\Leftarrow\; \textbf{the building block is unbroken} \;\Leftarrow\; \textbf{the arithmetic is hard}.$$

This is the soul of provable cryptography. We did not assert that any hash is
secure by fiat. We *transferred* the hardness: breaking the hash would mean
breaking the building block, and breaking the building block would mean solving
a problem we have every reason to believe is hard. Trust flows downhill, from
the towering construction to the bedrock assumption.

It is worth savoring how much of this is *combinatorial* rather than
probabilistic. The extraction theorem uses no coin flips, no "with high
probability," no asymptotics. It is an explicit, deterministic algorithm:
collision in, collision out. The fuzzy, statistical reputation of cryptography
melts away to reveal a crisp piece of discrete mathematics underneath.

And it ends, fittingly, with a number. The next time your computer verifies a
download or your wallet signs a transaction, remember the humble lesson of
$210 = 6 \times 35 = 10 \times 21$: a hash is only ever as strong as the
arithmetic that hides inside it.
