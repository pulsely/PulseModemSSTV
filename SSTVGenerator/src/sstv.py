# from pysstv.sstv import SSTV
from PIL import Image
from pysstv import color, grayscale
import uuid, json, os


# https://gist.github.com/sigilioso/2957026
def resize_and_crop(img, modified_path, size, crop_type='top'):
    """
    Resize and crop an image to fit the specified size.
    args:
        img_path: path for the image to resize.
        modified_path: path to store the modified image.
        size: `(width, height)` tuple.
        crop_type: can be 'top', 'middle' or 'bottom', depending on this
            value, the image will cropped getting the 'top/left', 'midle' or
            'bottom/rigth' of the image to fit the size.
    raises:
        Exception: if can not open the file in img_path of there is problems
            to save the image.
        ValueError: if an invalid `crop_type` is provided.
    """
    # If height is higher we resize vertically, if not we resize horizontally

    # Get current and desired ratio for the images
    img_ratio = img.size[0] / float(img.size[1])
    ratio = size[0] / float(size[1])
    #The image is scaled/cropped vertically or horizontally depending on the ratio
    if ratio > img_ratio:
        img = img.resize((size[0], int(size[0] * img.size[1] / img.size[0])),
                Image.ANTIALIAS)
        # Crop in the top, middle or bottom
        if crop_type == 'top':
            box = (0, 0, img.size[0], size[1])
        elif crop_type == 'middle':
            box = (0, (img.size[1] - size[1]) / 2, img.size[0], (img.size[1] + size[1]) / 2)
        elif crop_type == 'bottom':
            box = (0, img.size[1] - size[1], img.size[0], img.size[1])
        else :
            raise ValueError('ERROR: invalid value for crop_type')

        #print(">> box1: %s" % box)
        img = img.crop(box)
    elif ratio < img_ratio:
        img = img.resize(( int(size[1] * img.size[0] / img.size[1]), size[1]),
                Image.ANTIALIAS)
        # Crop in the top, middle or bottom
        if crop_type == 'top':
            box = (0, 0, size[0], img.size[1])
        elif crop_type == 'middle':
            box = ((img.size[0] - size[0]) / 2, 0, (img.size[0] + size[0]) / 2, img.size[1])
        elif crop_type == 'bottom':
            box = (img.size[0] - size[0], 0, img.size[0], img.size[1])
        else :
            raise ValueError('ERROR: invalid value for crop_type')
        #print(">> box2: %s" % box)
        img = img.crop(box)
    else:
        #print(">> else")

        img = img.resize((size[0], size[1]),
                Image.ANTIALIAS)
        # If the scale is the same, we do not need to crop
    return img


def modules():
    SSTV_MODULES = [color, grayscale]

    module_map = {}
    for module in SSTV_MODULES:
        for mode in module.MODES:
            module_map[mode.__name__] = mode
    return module_map

def sstv_formats():


    sstv_formats = []

    for key, value in modules().iteritems():
        sstv_formats.append({
            'name': key,
            'height': value.HEIGHT,
            'width': value.WIDTH,
        })
    return sstv_formats

def convert_image( temporary_folder, the_mode, path):
    img = Image.open(path, 'r')
    #img.thumbnail((80, 80), Image.ANTIALIAS)

    (img_width, img_height) = img.size

    print(u"Image width: %d X %d" % (img_width, img_height) )
    mode = modules()[ the_mode ]

    print(u"mode: %s" % mode)
    
    wave_filename = "%s.wav" % uuid.uuid4()
    wave_file = os.path.join( temporary_folder.replace("file://", ""), wave_filename )
    
    # if there is an image too small
    if not all(i >= m for i, m in zip(img.size, (mode.WIDTH, mode.HEIGHT))):
        error_msg = 'Error: Image must be at least %s x %s pixels for mode %s' % (mode.WIDTH, mode.HEIGHT, mode.__name__)
        payload = {
            'error' : error_msg,
            'text' : "Unable to generate image"
        }
        print(u"error_msg: %s" % error_msg)

        return ""
    else:
        if not ((img_width == mode.WIDTH) and (img_height == mode.HEIGHT)):
            # resize the image?
            img = resize_and_crop( img, path, (mode.WIDTH, mode.HEIGHT), crop_type='middle' )
            #img.save( tmp )
            #print(u">> image resized")

        #print(u">> converting SSTV file")
        sstv = mode(img, 44100, 16)
        sstv.vox_enabled = True

#        print(">> image dimension: %s" % (img.size,))
#        print(u">> writing wav file: %s" % wave_file)

        sstv.write_wav( wave_file )
        
        #print(f">> written to: {wave_file}")
        return wave_file

def sample_conversion():
    convert_image("Robot36", "/Users/kenneth/Pictures/tmp4.png")

if __name__ == '__main__':
   sample_conversion()
