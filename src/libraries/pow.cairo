mod errors {
    pub const DECIMALS_OUT_OF_RANGE: felt252 = 'POW_DEC_TOO_LARGE';
}

const SCALE: felt252 = 1000000000000000000000000000;

// Lookup-table seems to be the most gas-efficient
pub fn two_pow(power: felt252) -> felt252 {
    if power == 0 {
        0x1
    } else if power == 1 {
        0x2
    } else if power == 2 {
        0x4
    } else if power == 3 {
        0x8
    } else if power == 4 {
        0x10
    } else if power == 5 {
        0x20
    } else if power == 6 {
        0x40
    } else if power == 7 {
        0x80
    } else if power == 8 {
        0x100
    } else if power == 9 {
        0x200
    } else if power == 10 {
        0x400
    } else if power == 11 {
        0x800
    } else if power == 12 {
        0x1000
    } else if power == 13 {
        0x2000
    } else if power == 14 {
        0x4000
    } else if power == 15 {
        0x8000
    } else if power == 16 {
        0x10000
    } else if power == 17 {
        0x20000
    } else if power == 18 {
        0x40000
    } else if power == 19 {
        0x80000
    } else if power == 20 {
        0x100000
    } else if power == 21 {
        0x200000
    } else if power == 22 {
        0x400000
    } else if power == 23 {
        0x800000
    } else if power == 24 {
        0x1000000
    } else if power == 25 {
        0x2000000
    } else if power == 26 {
        0x4000000
    } else if power == 27 {
        0x8000000
    } else if power == 28 {
        0x10000000
    } else if power == 29 {
        0x20000000
    } else if power == 30 {
        0x40000000
    } else if power == 31 {
        0x80000000
    } else if power == 32 {
        0x100000000
    } else if power == 33 {
        0x200000000
    } else if power == 34 {
        0x400000000
    } else if power == 35 {
        0x800000000
    } else if power == 36 {
        0x1000000000
    } else if power == 37 {
        0x2000000000
    } else if power == 38 {
        0x4000000000
    } else if power == 39 {
        0x8000000000
    } else if power == 40 {
        0x10000000000
    } else if power == 41 {
        0x20000000000
    } else if power == 42 {
        0x40000000000
    } else if power == 43 {
        0x80000000000
    } else if power == 44 {
        0x100000000000
    } else if power == 45 {
        0x200000000000
    } else if power == 46 {
        0x400000000000
    } else if power == 47 {
        0x800000000000
    } else if power == 48 {
        0x1000000000000
    } else if power == 49 {
        0x2000000000000
    } else if power == 50 {
        0x4000000000000
    } else if power == 51 {
        0x8000000000000
    } else if power == 52 {
        0x10000000000000
    } else if power == 53 {
        0x20000000000000
    } else if power == 54 {
        0x40000000000000
    } else if power == 55 {
        0x80000000000000
    } else if power == 56 {
        0x100000000000000
    } else if power == 57 {
        0x200000000000000
    } else if power == 58 {
        0x400000000000000
    } else if power == 59 {
        0x800000000000000
    } else if power == 60 {
        0x1000000000000000
    } else if power == 61 {
        0x2000000000000000
    } else if power == 62 {
        0x4000000000000000
    } else if power == 63 {
        0x8000000000000000
    } else if power == 64 {
        0x10000000000000000
    } else if power == 65 {
        0x20000000000000000
    } else if power == 66 {
        0x40000000000000000
    } else if power == 67 {
        0x80000000000000000
    } else if power == 68 {
        0x100000000000000000
    } else if power == 69 {
        0x200000000000000000
    } else if power == 70 {
        0x400000000000000000
    } else if power == 71 {
        0x800000000000000000
    } else if power == 72 {
        0x1000000000000000000
    } else if power == 73 {
        0x2000000000000000000
    } else if power == 74 {
        0x4000000000000000000
    } else if power == 75 {
        0x8000000000000000000
    } else if power == 76 {
        0x10000000000000000000
    } else if power == 77 {
        0x20000000000000000000
    } else if power == 78 {
        0x40000000000000000000
    } else if power == 79 {
        0x80000000000000000000
    } else if power == 80 {
        0x100000000000000000000
    } else if power == 81 {
        0x200000000000000000000
    } else if power == 82 {
        0x400000000000000000000
    } else if power == 83 {
        0x800000000000000000000
    } else if power == 84 {
        0x1000000000000000000000
    } else if power == 85 {
        0x2000000000000000000000
    } else if power == 86 {
        0x4000000000000000000000
    } else if power == 87 {
        0x8000000000000000000000
    } else if power == 88 {
        0x10000000000000000000000
    } else if power == 89 {
        0x20000000000000000000000
    } else if power == 90 {
        0x40000000000000000000000
    } else if power == 91 {
        0x80000000000000000000000
    } else if power == 92 {
        0x100000000000000000000000
    } else if power == 93 {
        0x200000000000000000000000
    } else if power == 94 {
        0x400000000000000000000000
    } else if power == 95 {
        0x800000000000000000000000
    } else if power == 96 {
        0x1000000000000000000000000
    } else if power == 97 {
        0x2000000000000000000000000
    } else if power == 98 {
        0x4000000000000000000000000
    } else if power == 99 {
        0x8000000000000000000000000
    } else if power == 100 {
        0x10000000000000000000000000
    } else if power == 101 {
        0x20000000000000000000000000
    } else if power == 102 {
        0x40000000000000000000000000
    } else if power == 103 {
        0x80000000000000000000000000
    } else if power == 104 {
        0x100000000000000000000000000
    } else if power == 105 {
        0x200000000000000000000000000
    } else if power == 106 {
        0x400000000000000000000000000
    } else if power == 107 {
        0x800000000000000000000000000
    } else if power == 108 {
        0x1000000000000000000000000000
    } else if power == 109 {
        0x2000000000000000000000000000
    } else if power == 110 {
        0x4000000000000000000000000000
    } else if power == 111 {
        0x8000000000000000000000000000
    } else if power == 112 {
        0x10000000000000000000000000000
    } else if power == 113 {
        0x20000000000000000000000000000
    } else if power == 114 {
        0x40000000000000000000000000000
    } else if power == 115 {
        0x80000000000000000000000000000
    } else if power == 116 {
        0x100000000000000000000000000000
    } else if power == 117 {
        0x200000000000000000000000000000
    } else if power == 118 {
        0x400000000000000000000000000000
    } else if power == 119 {
        0x800000000000000000000000000000
    } else if power == 120 {
        0x1000000000000000000000000000000
    } else if power == 121 {
        0x2000000000000000000000000000000
    } else if power == 122 {
        0x4000000000000000000000000000000
    } else if power == 123 {
        0x8000000000000000000000000000000
    } else if power == 124 {
        0x10000000000000000000000000000000
    } else if power == 125 {
        0x20000000000000000000000000000000
    } else if power == 126 {
        0x40000000000000000000000000000000
    } else if power == 127 {
        0x80000000000000000000000000000000
    } else if power == 128 {
        0x100000000000000000000000000000000
    } else if power == 129 {
        0x200000000000000000000000000000000
    } else if power == 130 {
        0x400000000000000000000000000000000
    } else if power == 131 {
        0x800000000000000000000000000000000
    } else if power == 132 {
        0x1000000000000000000000000000000000
    } else if power == 133 {
        0x2000000000000000000000000000000000
    } else if power == 134 {
        0x4000000000000000000000000000000000
    } else if power == 135 {
        0x8000000000000000000000000000000000
    } else if power == 136 {
        0x10000000000000000000000000000000000
    } else if power == 137 {
        0x20000000000000000000000000000000000
    } else if power == 138 {
        0x40000000000000000000000000000000000
    } else if power == 139 {
        0x80000000000000000000000000000000000
    } else if power == 140 {
        0x100000000000000000000000000000000000
    } else if power == 141 {
        0x200000000000000000000000000000000000
    } else if power == 142 {
        0x400000000000000000000000000000000000
    } else if power == 143 {
        0x800000000000000000000000000000000000
    } else if power == 144 {
        0x1000000000000000000000000000000000000
    } else if power == 145 {
        0x2000000000000000000000000000000000000
    } else if power == 146 {
        0x4000000000000000000000000000000000000
    } else if power == 147 {
        0x8000000000000000000000000000000000000
    } else if power == 148 {
        0x10000000000000000000000000000000000000
    } else if power == 149 {
        0x20000000000000000000000000000000000000
    } else if power == 150 {
        0x40000000000000000000000000000000000000
    } else if power == 151 {
        0x80000000000000000000000000000000000000
    } else if power == 152 {
        0x100000000000000000000000000000000000000
    } else if power == 153 {
        0x200000000000000000000000000000000000000
    } else if power == 154 {
        0x400000000000000000000000000000000000000
    } else if power == 155 {
        0x800000000000000000000000000000000000000
    } else if power == 156 {
        0x1000000000000000000000000000000000000000
    } else if power == 157 {
        0x2000000000000000000000000000000000000000
    } else if power == 158 {
        0x4000000000000000000000000000000000000000
    } else if power == 159 {
        0x8000000000000000000000000000000000000000
    } else if power == 160 {
        0x10000000000000000000000000000000000000000
    } else if power == 161 {
        0x20000000000000000000000000000000000000000
    } else if power == 162 {
        0x40000000000000000000000000000000000000000
    } else if power == 163 {
        0x80000000000000000000000000000000000000000
    } else if power == 164 {
        0x100000000000000000000000000000000000000000
    } else if power == 165 {
        0x200000000000000000000000000000000000000000
    } else if power == 166 {
        0x400000000000000000000000000000000000000000
    } else if power == 167 {
        0x800000000000000000000000000000000000000000
    } else if power == 168 {
        0x1000000000000000000000000000000000000000000
    } else if power == 169 {
        0x2000000000000000000000000000000000000000000
    } else if power == 170 {
        0x4000000000000000000000000000000000000000000
    } else if power == 171 {
        0x8000000000000000000000000000000000000000000
    } else if power == 172 {
        0x10000000000000000000000000000000000000000000
    } else if power == 173 {
        0x20000000000000000000000000000000000000000000
    } else if power == 174 {
        0x40000000000000000000000000000000000000000000
    } else if power == 175 {
        0x80000000000000000000000000000000000000000000
    } else if power == 176 {
        0x100000000000000000000000000000000000000000000
    } else if power == 177 {
        0x200000000000000000000000000000000000000000000
    } else if power == 178 {
        0x400000000000000000000000000000000000000000000
    } else if power == 179 {
        0x800000000000000000000000000000000000000000000
    } else if power == 180 {
        0x1000000000000000000000000000000000000000000000
    } else if power == 181 {
        0x2000000000000000000000000000000000000000000000
    } else if power == 182 {
        0x4000000000000000000000000000000000000000000000
    } else if power == 183 {
        0x8000000000000000000000000000000000000000000000
    } else if power == 184 {
        0x10000000000000000000000000000000000000000000000
    } else if power == 185 {
        0x20000000000000000000000000000000000000000000000
    } else if power == 186 {
        0x40000000000000000000000000000000000000000000000
    } else if power == 187 {
        0x80000000000000000000000000000000000000000000000
    } else if power == 188 {
        0x100000000000000000000000000000000000000000000000
    } else if power == 189 {
        0x200000000000000000000000000000000000000000000000
    } else if power == 190 {
        0x400000000000000000000000000000000000000000000000
    } else if power == 191 {
        0x800000000000000000000000000000000000000000000000
    } else if power == 192 {
        0x1000000000000000000000000000000000000000000000000
    } else if power == 193 {
        0x2000000000000000000000000000000000000000000000000
    } else if power == 194 {
        0x4000000000000000000000000000000000000000000000000
    } else if power == 195 {
        0x8000000000000000000000000000000000000000000000000
    } else if power == 196 {
        0x10000000000000000000000000000000000000000000000000
    } else if power == 197 {
        0x20000000000000000000000000000000000000000000000000
    } else if power == 198 {
        0x40000000000000000000000000000000000000000000000000
    } else if power == 199 {
        0x80000000000000000000000000000000000000000000000000
    } else if power == 200 {
        0x100000000000000000000000000000000000000000000000000
    } else if power == 201 {
        0x200000000000000000000000000000000000000000000000000
    } else if power == 202 {
        0x400000000000000000000000000000000000000000000000000
    } else if power == 203 {
        0x800000000000000000000000000000000000000000000000000
    } else if power == 204 {
        0x1000000000000000000000000000000000000000000000000000
    } else if power == 205 {
        0x2000000000000000000000000000000000000000000000000000
    } else if power == 206 {
        0x4000000000000000000000000000000000000000000000000000
    } else if power == 207 {
        0x8000000000000000000000000000000000000000000000000000
    } else if power == 208 {
        0x10000000000000000000000000000000000000000000000000000
    } else if power == 209 {
        0x20000000000000000000000000000000000000000000000000000
    } else if power == 210 {
        0x40000000000000000000000000000000000000000000000000000
    } else if power == 211 {
        0x80000000000000000000000000000000000000000000000000000
    } else if power == 212 {
        0x100000000000000000000000000000000000000000000000000000
    } else if power == 213 {
        0x200000000000000000000000000000000000000000000000000000
    } else if power == 214 {
        0x400000000000000000000000000000000000000000000000000000
    } else if power == 215 {
        0x800000000000000000000000000000000000000000000000000000
    } else if power == 216 {
        0x1000000000000000000000000000000000000000000000000000000
    } else if power == 217 {
        0x2000000000000000000000000000000000000000000000000000000
    } else if power == 218 {
        0x4000000000000000000000000000000000000000000000000000000
    } else if power == 219 {
        0x8000000000000000000000000000000000000000000000000000000
    } else if power == 220 {
        0x10000000000000000000000000000000000000000000000000000000
    } else if power == 221 {
        0x20000000000000000000000000000000000000000000000000000000
    } else if power == 222 {
        0x40000000000000000000000000000000000000000000000000000000
    } else if power == 223 {
        0x80000000000000000000000000000000000000000000000000000000
    } else if power == 224 {
        0x100000000000000000000000000000000000000000000000000000000
    } else if power == 225 {
        0x200000000000000000000000000000000000000000000000000000000
    } else if power == 226 {
        0x400000000000000000000000000000000000000000000000000000000
    } else if power == 227 {
        0x800000000000000000000000000000000000000000000000000000000
    } else if power == 228 {
        0x1000000000000000000000000000000000000000000000000000000000
    } else if power == 229 {
        0x2000000000000000000000000000000000000000000000000000000000
    } else if power == 230 {
        0x4000000000000000000000000000000000000000000000000000000000
    } else if power == 231 {
        0x8000000000000000000000000000000000000000000000000000000000
    } else if power == 232 {
        0x10000000000000000000000000000000000000000000000000000000000
    } else if power == 233 {
        0x20000000000000000000000000000000000000000000000000000000000
    } else if power == 234 {
        0x40000000000000000000000000000000000000000000000000000000000
    } else if power == 235 {
        0x80000000000000000000000000000000000000000000000000000000000
    } else if power == 236 {
        0x100000000000000000000000000000000000000000000000000000000000
    } else if power == 237 {
        0x200000000000000000000000000000000000000000000000000000000000
    } else if power == 238 {
        0x400000000000000000000000000000000000000000000000000000000000
    } else if power == 239 {
        0x800000000000000000000000000000000000000000000000000000000000
    } else if power == 240 {
        0x1000000000000000000000000000000000000000000000000000000000000
    } else if power == 241 {
        0x2000000000000000000000000000000000000000000000000000000000000
    } else if power == 242 {
        0x4000000000000000000000000000000000000000000000000000000000000
    } else if power == 243 {
        0x8000000000000000000000000000000000000000000000000000000000000
    } else if power == 244 {
        0x10000000000000000000000000000000000000000000000000000000000000
    } else if power == 245 {
        0x20000000000000000000000000000000000000000000000000000000000000
    } else if power == 246 {
        0x40000000000000000000000000000000000000000000000000000000000000
    } else if power == 247 {
        0x80000000000000000000000000000000000000000000000000000000000000
    } else if power == 248 {
        0x100000000000000000000000000000000000000000000000000000000000000
    } else if power == 249 {
        0x200000000000000000000000000000000000000000000000000000000000000
    } else if power == 250 {
        0x400000000000000000000000000000000000000000000000000000000000000
    } else if power == 251 {
        0x800000000000000000000000000000000000000000000000000000000000000
    } else {
        core::panic_with_felt252(errors::DECIMALS_OUT_OF_RANGE)
    }
}

// Lookup-table seems to be the most gas-efficient
pub fn ten_pow(power: felt252) -> felt252 {
    if power == 0 {
        1
    } else if power == 1 {
        10
    } else if power == 2 {
        100
    } else if power == 3 {
        1000
    } else if power == 4 {
        10000
    } else if power == 5 {
        100000
    } else if power == 6 {
        1000000
    } else if power == 7 {
        10000000
    } else if power == 8 {
        100000000
    } else if power == 9 {
        1000000000
    } else if power == 10 {
        10000000000
    } else if power == 11 {
        100000000000
    } else if power == 12 {
        1000000000000
    } else if power == 13 {
        10000000000000
    } else if power == 14 {
        100000000000000
    } else if power == 15 {
        1000000000000000
    } else if power == 16 {
        10000000000000000
    } else if power == 17 {
        100000000000000000
    } else if power == 18 {
        1000000000000000000
    } else if power == 19 {
        10000000000000000000
    } else if power == 20 {
        100000000000000000000
    } else if power == 21 {
        1000000000000000000000
    } else if power == 22 {
        10000000000000000000000
    } else if power == 23 {
        100000000000000000000000
    } else if power == 24 {
        1000000000000000000000000
    } else if power == 25 {
        10000000000000000000000000
    } else if power == 26 {
        100000000000000000000000000
    } else if power == 27 {
        1000000000000000000000000000
    } else if power == 28 {
        10000000000000000000000000000
    } else if power == 29 {
        100000000000000000000000000000
    } else if power == 30 {
        1000000000000000000000000000000
    } else if power == 31 {
        10000000000000000000000000000000
    } else if power == 32 {
        100000000000000000000000000000000
    } else if power == 33 {
        1000000000000000000000000000000000
    } else if power == 34 {
        10000000000000000000000000000000000
    } else if power == 35 {
        100000000000000000000000000000000000
    } else if power == 36 {
        1000000000000000000000000000000000000
    } else if power == 37 {
        10000000000000000000000000000000000000
    } else if power == 38 {
        100000000000000000000000000000000000000
    } else if power == 39 {
        1000000000000000000000000000000000000000
    } else if power == 40 {
        10000000000000000000000000000000000000000
    } else if power == 41 {
        100000000000000000000000000000000000000000
    } else if power == 42 {
        1000000000000000000000000000000000000000000
    } else if power == 43 {
        10000000000000000000000000000000000000000000
    } else if power == 44 {
        100000000000000000000000000000000000000000000
    } else if power == 45 {
        1000000000000000000000000000000000000000000000
    } else if power == 46 {
        10000000000000000000000000000000000000000000000
    } else if power == 47 {
        100000000000000000000000000000000000000000000000
    } else if power == 48 {
        1000000000000000000000000000000000000000000000000
    } else if power == 49 {
        10000000000000000000000000000000000000000000000000
    } else if power == 50 {
        100000000000000000000000000000000000000000000000000
    } else if power == 51 {
        1000000000000000000000000000000000000000000000000000
    } else if power == 52 {
        10000000000000000000000000000000000000000000000000000
    } else if power == 53 {
        100000000000000000000000000000000000000000000000000000
    } else if power == 54 {
        1000000000000000000000000000000000000000000000000000000
    } else if power == 55 {
        10000000000000000000000000000000000000000000000000000000
    } else if power == 56 {
        100000000000000000000000000000000000000000000000000000000
    } else if power == 57 {
        1000000000000000000000000000000000000000000000000000000000
    } else if power == 58 {
        10000000000000000000000000000000000000000000000000000000000
    } else if power == 59 {
        100000000000000000000000000000000000000000000000000000000000
    } else if power == 60 {
        1000000000000000000000000000000000000000000000000000000000000
    } else if power == 61 {
        10000000000000000000000000000000000000000000000000000000000000
    } else if power == 62 {
        100000000000000000000000000000000000000000000000000000000000000
    } else if power == 63 {
        1000000000000000000000000000000000000000000000000000000000000000
    } else if power == 64 {
        10000000000000000000000000000000000000000000000000000000000000000
    } else if power == 65 {
        100000000000000000000000000000000000000000000000000000000000000000
    } else if power == 66 {
        1000000000000000000000000000000000000000000000000000000000000000000
    } else if power == 67 {
        10000000000000000000000000000000000000000000000000000000000000000000
    } else if power == 68 {
        100000000000000000000000000000000000000000000000000000000000000000000
    } else if power == 69 {
        1000000000000000000000000000000000000000000000000000000000000000000000
    } else if power == 70 {
        10000000000000000000000000000000000000000000000000000000000000000000000
    } else if power == 71 {
        100000000000000000000000000000000000000000000000000000000000000000000000
    } else if power == 72 {
        1000000000000000000000000000000000000000000000000000000000000000000000000
    } else if power == 73 {
        10000000000000000000000000000000000000000000000000000000000000000000000000
    } else if power == 74 {
        100000000000000000000000000000000000000000000000000000000000000000000000000
    } else if power == 75 {
        1000000000000000000000000000000000000000000000000000000000000000000000000000
    } else {
        core::panic_with_felt252(errors::DECIMALS_OUT_OF_RANGE)
    }
}
#[cfg(test)]
mod tests {
    // use test::test_utils::assert_eq!;

    #[test]
    fn test_two_pow() {
        assert_eq!(@super::two_pow(0), @1, "FAILED");
        assert_eq!(@super::two_pow(1), @2, "FAILED");
        assert_eq!(@super::two_pow(2), @4, "FAILED");
        assert_eq!(@super::two_pow(3), @8, "FAILED");
        assert_eq!(@super::two_pow(4), @16, "FAILED");
        assert_eq!(@super::two_pow(5), @32, "FAILED");
        assert_eq!(@super::two_pow(100), @0x10000000000000000000000000, "FAILED");
        assert_eq!(@super::two_pow(101), @0x20000000000000000000000000, "FAILED");
        assert_eq!(
            @super::two_pow(251),
            @0x800000000000000000000000000000000000000000000000000000000000000,
            "FAILED"
        );
    }

    #[test]
    #[should_panic(expected: ('POW_DEC_TOO_LARGE',))]
    fn test_two_pow_overflow() {
        super::two_pow(252);
    }

    #[test]
    fn test_ten_pow() {
        assert_eq!(@super::ten_pow(0), @1, "FAILED");
        assert_eq!(@super::ten_pow(1), @10, "FAILED");
        assert_eq!(@super::ten_pow(2), @100, "FAILED");
        assert_eq!(@super::ten_pow(3), @1000, "FAILED");
        assert_eq!(@super::ten_pow(4), @10000, "FAILED");
        assert_eq!(@super::ten_pow(5), @100000, "FAILED");
        assert_eq!(
            @super::ten_pow(75),
            @1000000000000000000000000000000000000000000000000000000000000000000000000000,
            "FAILED"
        );
    }

    #[test]
    #[should_panic(expected: ('POW_DEC_TOO_LARGE',))]
    fn test_ten_pow_overflow() {
        super::ten_pow(76);
    }
}

