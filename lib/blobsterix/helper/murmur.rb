#only usefull to hash strings
class Murmur
  def self.force_overflow_signed(i)
    force_overflow_unsigned(i + 2**31) - 2**31
  end

  def self.force_overflow_unsigned_16(i)
    i % 2**16   # or equivalently: i & 0xffffffff
  end

  def self.force_overflow_unsigned(i)
    i % 2**32   # or equivalently: i & 0xffffffff
  end

  def self.force_overflow_unsigned_64(i)
    i % 2**64   # or equivalently: i & 0xffffffff
  end

  #64bit processors
  def self.Hash64A (key)
    len = key.size
    seed = 11

    m = 0xc6a4a7935bd1e995
    r = 47

    h = seed ^ len;

    data = String.new(key)

    while len >= 8
      k = data.slice!(0..7).unpack("Q")[0]

      k = force_overflow_unsigned_64(k * m)
      k ^= k >> r
      k = force_overflow_unsigned_64(k * m)

      h ^= k;
      h = force_overflow_unsigned_64(h * m)

      len-=8
    end

    h ^= data.slice(6).to_i << 48 if len == 7
    h ^= data.slice(5).to_i << 40 if len >= 6
    h ^= data.slice(4).to_i << 32 if len >= 5
    h ^= data.slice(3).to_i << 24 if len >= 4
    h ^= data.slice(2).to_i << 16 if len >= 3
    h ^= data.slice(1).to_i << 8 if len >= 2
    h ^= data.slice(0).to_i if len >= 1

    h = force_overflow_unsigned_64(h * m) if len

    h ^= h >> r
    h = force_overflow_unsigned_64(h * m)
    h ^= h >> r

    h
  end

  def self.get_num(num)
    return num if num.class == Fixnum
    num.to_s.unpack("C")[0]
  end

  #32bit processors
  def self.Hash64B(key)
    len = key.size
    seed = 11

    m = 0x5bd1e995 #1540483477
    r = 24

    h1 = seed ^ len
    h2 = 0

    data = String.new(key)#.force_encoding('ASCII-8BIT')
    
    while len >= 8
      k1 = data.slice!(0..3).unpack("I")[0]

      k1 = force_overflow_unsigned(k1 * m)
      k1 ^= k1 >> r

      k1 = force_overflow_unsigned(k1 * m)
      h1 = force_overflow_unsigned(h1 * m)

      h1 ^= k1
      len -= 4


      k2 = data.slice!(0..3).unpack("I")[0]

      k2 = force_overflow_unsigned(k2 * m)
      k2 ^= k2 >> r

      k2 = force_overflow_unsigned(k2 * m)
      h2 = force_overflow_unsigned(h2 * m)

      h2 ^= k2
      len -= 4
    end

    if len >= 4
      k1 = data.slice!(0..3).unpack("I")[0]

      k1 = force_overflow_unsigned(k1 * m)
      k1 ^= k1 >> r

      k1 = force_overflow_unsigned(k1 * m)
      h1 = force_overflow_unsigned(h1 * m)

      h1 ^= k1
      len -= 4
    end

    h2 ^= (get_num(data[2]) << 16) if len == 3
    h2 ^= (get_num(data[1]) << 8).to_i if len >= 2
    h2 ^= (get_num(data[0])) if len >= 1

    h2 = force_overflow_unsigned(h2 * m) if len > 0

    h1 ^= h2 >> 18
    h1 = force_overflow_unsigned(h1 * m)

    h2 ^= h1 >> 22
    h2 = force_overflow_unsigned(h2 * m)

    h1 ^= h2 >> 17
    h1 = force_overflow_unsigned(h1 * m)

    h = h1
    h = (h << 32) | h2

    h
  end

  def self.map_filename(filename, *additional)
    hash = Murmur.Hash64B(filename)
    bits =  hash.to_s(2)
    parts = []
    6.times { |index|
      len = 11
      len = bits.length if len >= bits.length
      value = bits.slice!(0, len).to_i(2).to_s(16).rjust(3,"0")
      parts.push(value)
    }
    parts = parts+additional
    parts.join("/")
  end
end
