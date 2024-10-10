static inline int my_clz(uint32_t x) {
    if (x == 0) return 32;
    int count = 0;
    if ((int32_t)x < 0) return 0; // x sign bit is 1， number of leading zero is 0.
    for (int i = 31; i >= 0; --i) {
        if (x & (1U << i))
            break;
        count++;
    }
    return count;
}
int singleNumber(int* nums, int numsSize) {
    int result = 0;
    int min_leading_zeros = 32;  
    
    for (int i = 0; i < numsSize; i++) {
        if (nums[i] != 0) {
            int leading_zeros = my_clz((uint32_t)nums[i]);
            if (leading_zeros < min_leading_zeros) {
                min_leading_zeros = leading_zeros;
            }
        }
    }
    
    for (int i = 0; i < 32 - min_leading_zeros; i++) {
        int count = 0;
        for (int j = 0; j < numsSize; j++) {
            if (nums[j] & (1U << i)) {
                count++;
            }
        }
        if (count % 3 != 0) {
            result |= (1U << i);
        }
    }
    
    return result;
}