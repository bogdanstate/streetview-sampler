# streetview-sampler
Helper functions for sampling points on a road network and downloading associated Google Streetview images.

I am providing code in this repository to you under an open source license. Because this is my personal repository, the license you receive to my code is from me and not from my employer (Facebook).

How to install:

1. Clone this repository:
```
git clone https://github.com/bogdanstate/streetview-sampler.git
```

2. In the directory in which `streetview-sampler` was cloned, create and activate a virtualenv to ensure we're using Python 2.7:
```
virtualenv -p python2.7 env
source env/bin/activate
```

3. Clone the robolyst/streetview package for interacting with the Streetview API:
```
git clone https://github.com/robolyst/streetview.git
```

4. Install other required pip modules:
```
pip install requests pillow
```

5. Update `PYTHONPATH` environment variable to pick up virtualenv packages:
```
export PYTHONPATH=env/lib/python2.7/site-packages
```
