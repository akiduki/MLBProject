
## tips for using OpenCV with Anaconda Python, Xcode
>OpenCV is sooo buggy... Everytime I came across opencv, I would spend a hell lot of time setting up the environment. Whether working with python, C++, Xcode....
OK now I finally got a chance to write some tips down, HOPE THIS WOULD HELP! \*3*


*** 
**Mac OS Yosemite 10.10.2 || Xcode 6.1.1  || opencv 2.4.10.1** 

Opencv can be got from   

- cmake
- homebrew install opencv
- conda install opencv

I have the first 2 versions installed. (I deleted the conda version. But not sure how to completely romove the cmake version.)


***

## 1. If you want to install opencv using homebrew: 
**homebrew requires linking numpy before installing opencv, but it can't link numpy because of some access error (Permission denied).**

#### so...add access by the command "change owner"
<span style="color:hotpink">**_sudo chown -R chenge /usr/local_**</span>

![add acess](brew_install.png =500x200)

#### Now you should be able to "<span style="color:hotpink">brew link numpy</span>", and then you can go ahead and "<span style="color:hotpink">brew install opencv</span>".


	172-16-208-183:1.9.1 Chenge$ brew link numpy
	Linking /usr/local/Cellar/numpy/1.9.1... 391 symlinks created
	172-16-208-183:1.9.1 Chenge$ brew install opencv
	==> Installing opencv from homebrew/homebrew-science
	==> Downloading https://downloads.sf.net/project/machomebrew/Bottles/science/ope
	######################################################################## 100.0%
	==> Pouring opencv-2.4.10.1.yosemite.bottle.tar.gz
	Error: The `brew link` step did not complete successfully
	The formula built, but is not symlinked into /usr/local
	Could not symlink share/OpenCV/OpenCVConfig-version.cmake
	Target /usr/local/share/OpenCV/OpenCVConfig-version.cmake
	already exists. You may want to remove it:
	  rm '/usr/local/share/OpenCV/OpenCVConfig-version.cmake'

	To force the link and overwrite all conflicting files:
	  brew link --overwrite opencv

	To list all files that would be deleted:
	  brew link --overwrite --dry-run opencv

	Possible conflicting files are:
	//。。。。a lot of files here//
	==> Summary
	🍺  /usr/local/Cellar/opencv/2.4.10.1: 219 files,  39M
	172-16-208-183:1.9.1 Chenge$ rm /usr/local/share/OpenCV/OpenCVConfig-version.cmake
	172-16-208-183:1.9.1 Chenge$ brew link --overwrite opencv
	Linking /usr/local/Cellar/opencv/2.4.10.1... 93 symlinks created
	172-16-208-183:1.9.1 Chenge$ brew link --overwrite --dry-run opencv
	Warning: Already linked: /usr/local/Cellar/opencv/2.4.10.1
	To relink: brew unlink opencv && brew link opencv
	172-16-208-183:1.9.1 Chenge$ 
	
** There are some comflicting files because I already had the cmake version opencv installed. But I decided not to delete that and keep both. **


## 2. if you want to install opencv using Anaconda 

<span style="color:hotpink">**conda install -c https://conda.binstar.org/jjhelmus opencv**</span>

![reinstall opencv anaconda](reinstall_cv_ana.png =x300)


** Anaconda Python works fine with the conda version opencv.But I uninstalled Anaconda opencv:**
<span style="color:hotpink">conda uninstall opencv</span> ,
**because I chose to _link anaconda python with the brewed opencv instead_:**

* cd /Users/Chenge/anaconda/lib/python2.7/site-packages/ 
* ln -s /usr/local/Cellar/opencv/2.4.10.1/lib/python2.7/site-packages/cv.py cv.py
* ln -s /usr/local/Cellar/opencv/2.4.10.1/lib/python2.7/site-packages/cv2.so cv2.so

	`BTW, anoconda python path:`
/Users/Chenge/anaconda/lib/python2.7/site-packages/  
**there are packages like**: _/Users/Chenge/anaconda/lib/python2.7/site-packages/numpy_ )


***


## 3. Linking opencv with Xcode
### choice 1: linking the brewed version:
* Under "Build Phases", "Link Binary With Libraries"
* Under "Build Settings", "Library Search Paths" (Set to /usr/local/Cellar/opencv/2.4.10.1/lib)
* Unser "Build Settings", "Header Search Paths" (Set to /usr/local/Cellar/opencv/2.4.10.1/include)
* Last but not least, **you should add whatever dylib files you need to the project** by _Add Files to..._


### choice 2: linking the cmake version:
* Under "Build Phases", "Link Binary With Libraries"
* Under "Build Settings", "Library Search Paths" (Set to /usr/local/opt/opencv/lib)
* Unser "Build Settings", "Header Search Paths" (Set to /usr/local/opt/opencv/include/)  
* Last but not least, **you should add whatever dylib files you need to the project** by _Add Files to..._ 

	
	`BTW, cmake version of opencv is at`:
	/usr/local/opt/opencv/include/opencv
	/usr/local/opt/opencv/include/opencv2  
	/usr/local/opt/opencv/lib


<span style="color:blue">**If you don't know which version you should use, you can add them both...but this is not a neat idea.**</span>


**This might be helpful**: <https://syncknowledge.wordpress.com/2014/11/02/using-opencv-2-4-9-with-xcode-6-1-on-os-x-yosemite/>

##Now you should be able to:

- run Anaconda python with Anaconda opencv or homebrewed opencv.   
- use cmake version of opencv or homebrewed opencv in Xcode.  
- have no idea what I have just jabbered, still stuck somewhere nowhere? **Well...good luck! Or should I say, _google_ with luck~! :D**

*** 
### About opencv "segmentation fault 11"

Conda uninstall opencv doesn't delete cv files in the package folder. You need to delete the files manually if you want to link conda python with other CV (eg. Homebrewed OpenCV).

If there are still problems about segmentation fault. Try change the first line in **cv2.so** file.




##### About linking python to the homebrew version CV

useful links: https://gist.github.com/welch/6468594 
 

 ** firstly delted all 3 cv files in the site-packages folder:
  sudo rm cv.pyc
  sudo rm cv2.so
  sudo rm cv.py **
  
  ```
  And link:
 cd /Users/Chenge/anaconda/lib/python2.7/site-packages/ln -s /usr/local/Cellar/opencv/2.4.10.1/lib/python2.7/site-packages/cv.py cv.pyln -s /usr/local/Cellar/opencv/2.4.10.1/lib/python2.7/site-packages/cv2.so cv2.so
```

after linking the 2 files, the pyc file doesn't appear 

**change the first line!!**

```  
sudo install_name_tool -change libpython2.7.dylib(the first line) /Users/Chenge/anaconda/lib/libpython2.7.dylib /Users/Chenge/anaconda/lib/python2.7/site-packages/cv2.so
```

changed! still no pyc file, but
after run python>> pyc appears!




*** 
<lichenge0223@gmail.com>
