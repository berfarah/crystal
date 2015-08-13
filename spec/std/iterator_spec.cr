require "spec"
require "iterator"

describe Iterator do
  describe "compact_map" do
    it "applies the function and removes nil values" do
      iter = (1..3).each.compact_map {|e| e.odd? ? e : nil}
      iter.next.should eq(1)
      iter.next.should eq(3)
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq(1)
    end

    it "sums after compact_map to_a" do
      (1..3).each.compact_map {|e| e.odd? ? e : nil}.to_a.sum.should eq(4)
    end
  end

  describe "map" do
    it "does map with Range iterator" do
      iter = (1..3).each.map &.*(2)
      iter.next.should eq(2)
      iter.next.should eq(4)
      iter.next.should eq(6)
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq(2)
    end
  end

  describe "select" do
    it "does select with Range iterator" do
      iter = (1..3).each.select &.>=(2)
      iter.next.should eq(2)
      iter.next.should eq(3)
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq(2)
    end
  end

  describe "reject" do
    it "does reject with Range iterator" do
      iter = (1..3).each.reject &.>=(2)
      iter.next.should eq(1)
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq(1)
    end
  end

  describe "take" do
    it "does take with Range iterator" do
      iter = (1..3).each.take(2)
      iter.next.should eq(1)
      iter.next.should eq(2)
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq(1)
    end

    it "does take with more than available" do
      (1..3).each.take(10).to_a.should eq([1, 2, 3])
    end
  end

  describe "take_while" do
    it "does take_while with Range iterator" do
      iter = (1..5).each.take_while {|i| i < 3}
      iter.next.should eq(1)
      iter.next.should eq(2)
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq(1)
    end

    it "does take_while with more than available" do
      (1..3).each.take_while{true}.to_a.should eq([1, 2, 3])
    end

    it "only calls the block as much as needed" do
      called = 0
      iter = (1..5).each.take_while do |i|
        called += 1
        i < 3
      end
      5.times {iter.next}
      called.should eq 3
    end
  end

  describe "skip" do
    it "does skip with Range iterator" do
      iter = (1..3).each.skip(2)
      iter.next.should eq(3)
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq(3)
    end
  end

  describe "skip_while" do
    it "does skip_while with an array" do
      iter = [1, 2, 3, 4, 0].each.skip_while { |i| i < 3}
      iter.next.should eq(3)
      iter.next.should eq(4)
      iter.next.should eq(0)
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq(3)
    end

    it "can skip everything" do
      iter = (1..3).each.skip_while {true}
      iter.to_a.should eq [] of Int32
    end

    it "returns the full array if the condition is false for the first item" do
      iter = (1..2).each.skip_while {false}
      iter.to_a.should eq [1, 2]
    end

    it "only calls the block as much as needed" do
      called = 0
      iter = (1..5).each.skip_while do |i|
        called += 1
        i < 3
      end
      5.times {iter.next}
      called.should eq 3
    end
  end

  describe "zip" do
    it "does skip with Range iterator" do
      r1 = (1..3).each
      r2 = ('a'..'c').each
      iter = r1.zip(r2)
      iter.next.should eq({1, 'a'})
      iter.next.should eq({2, 'b'})
      iter.next.should eq({3, 'c'})
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq({1, 'a'})

      iter.rewind
      iter.to_a.should eq([{1, 'a'}, {2, 'b'}, {3, 'c'}])
    end
  end

  describe "cycle" do
    it "does cycle from range" do
      iter = (1..3).each.cycle
      iter.next.should eq(1)
      iter.next.should eq(2)
      iter.next.should eq(3)
      iter.next.should eq(1)
      iter.next.should eq(2)

      iter.rewind
      iter.next.should eq(1)
    end

    it "cycles an empty array" do
      ary = [] of Int32
      values = ary.each.cycle.to_a
      values.empty?.should be_true
    end

    it "cycles N times" do
      iter = (1..2).each.cycle(2)
      iter.next.should eq(1)
      iter.next.should eq(2)
      iter.next.should eq(1)
      iter.next.should eq(2)
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq(1)
    end
  end

  describe "in_groups_of" do
    it "creats groups of one" do
      iter = (1..3).each.in_groups_of(1)
      iter.next.should eq([1])
      iter.next.should eq([2])
      iter.next.should eq([3])
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq [1]
    end

    it "creats a group of two" do
      iter = (1..3).each.in_groups_of(2)
      iter.next.should eq([1, 2])
      iter.next.should eq([3, nil])
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq [1, 2]
    end

    it "fills up with the fill up argument" do
      iter = (1..3).each.in_groups_of(2, 'z')
      iter.next.should eq([1, 2])
      iter.next.should eq([3, 'z'])
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq [1, 2]
    end

    it "raises argument error if size is less than 0" do
      expect_raises ArgumentError, "size must be positive" do
        [1, 2, 3].each.in_groups_of(0)
      end
    end
  end

  describe "with_index" do
    it "does with_index from range" do
      iter = (1..3).each.with_index
      iter.next.should eq({1, 0})
      iter.next.should eq({2, 1})
      iter.next.should eq({3, 2})
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq({1, 0})
    end

    it "does with_index with offset from range" do
      iter = (1..3).each.with_index(10)
      iter.next.should eq({1, 10})
      iter.next.should eq({2, 11})
      iter.next.should eq({3, 12})
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq({1, 10})
    end
  end

  describe "with object" do
    it "does with object" do
      iter = (1..3).each.with_object("a")
      iter.next.should eq({1, "a"})
      iter.next.should eq({2, "a"})
      iter.next.should eq({3, "a"})
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq({1, "a"})
    end
  end

  describe "slice" do
    it "slices" do
      iter = (1..8).each.slice(3)
      iter.next.should eq([1, 2, 3])
      iter.next.should eq([4, 5, 6])
      iter.next.should eq([7, 8])
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq([1, 2, 3])
    end
  end

  describe "cons" do
    it "conses" do
      iter = (1..5).each.cons(3)
      iter.next.should eq([1, 2, 3])
      iter.next.should eq([2, 3, 4])
      iter.next.should eq([3, 4, 5])
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq([1, 2, 3])
    end
  end

  describe "uniq" do
    it "without block" do
      iter = (1..8).each.map { |x| x % 3 }.uniq
      iter.next.should eq(1)
      iter.next.should eq(2)
      iter.next.should eq(0)
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq(1)
    end

    it "with block" do
      iter = (1..8).each.uniq { |x| x % 3 }
      iter.next.should eq(1)
      iter.next.should eq(2)
      iter.next.should eq(3)
      iter.next.should be_a(Iterator::Stop)

      iter.rewind
      iter.next.should eq(1)
    end
  end

  it "creates singleton" do
    iter = Iterator.of(42)
    iter.take(3).to_a.should eq([42, 42, 42])
  end

  it "creates singleton from block" do
    a = 0
    iter = Iterator.of { a += 1 }
    iter.take(3).to_a.should eq([1, 2, 3])
  end

  it "chains" do
    iter = (1..2).each.chain(('a'..'b').each)
    iter.next.should eq(1)
    iter.next.should eq(2)
    iter.next.should eq('a')
    iter.next.should eq('b')
    iter.next.should be_a(Iterator::Stop)

    iter.rewind
    iter.next.should eq(1)

    iter.rewind
    iter.to_a.should eq([1, 2, 'a', 'b'])
  end

  it "taps" do
    a = 0

    iter = (1..3).each.tap { |x| a += x }
    iter.next.should eq(1)
    a.should eq(1)

    iter.next.should eq(2)
    a.should eq(3)

    iter.next.should eq(3)
    a.should eq(6)

    iter.next.should be_a(Iterator::Stop)

    iter.rewind
    iter.next.should eq(1)
  end

  it "combines many iterators" do
    (1..100).each
            .select { |x| 50 <= x < 60 }
            .map { |x| x * 2 }
            .take(3)
            .to_a
            .should eq([100, 102, 104])
  end
end
