If you want all the data, then you can make a GET request at '/'

If you want to get data for a specific platform and category then you can make a GET request at '/{category}/{platform}'
```Category and platform both will follow bit masking mechanism

``` In Category: 0th bit for men, 1st bit for women
``` In platform: 0th bit for Amazon, 1st bit for Flipkart, 2nd bit for Snapdeal
``` In platform or category, if all bits are unset then it'll be equivalent to all bits are set.