int singleNumber(int* nums, int numsSize) {
    int result = 0;

    for (int i = 0; i < 32; ++i) {  
        int count = 0;
        for (int j = 0; j < numsSize; ++j) {
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