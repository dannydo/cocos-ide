<?php

class Pixels {
    public $pixels = array();
    protected $x = 0;
    protected $y = 0;
    protected $fileName = "";


    function Pixels($filename = null){
        $this->load($filename);
        $this->fileName = $filename;
    }


    function load($filename, $whiteLevel = 0){
        $rawPixels = array();
        if($filename){

            $image = new Imagick($filename);

            $geometry = $image->getImageGeometry();

            $this->x = $geometry['width'];
            $this->y = $geometry['height'];

            $rawPixels = $this->imageToPixel($image);
        }
        $this->pixels = $rawPixels;
    }

    function imageToPixel($image){
        $rawPixels = array();
        $it = $image->getPixelIterator();

        /* Loop trough pixel rows */
        foreach( $it as $row => $pixels )
        {
            foreach ( $pixels as $column => $pixel )
            {
                $rawPixels[$column][$row] = $pixel->getColor();
            }

            $it->syncIterator();
        }
        return $rawPixels;
    }

    function getBoundingRect() {
        $xs = [];
        $ys = [];

        $colors = [];
        foreach ($this->pixels as $x => $row){
            foreach ($row as $y => $pixel){
                $color = implode(",", $pixel);
                @$colors[$color]++;
            }
        }
        $colorIndex = array_flip($colors);

        $background_color = [$colorIndex[max($colors)]=>true];
        /*
        $background_color = [];
        $sum = array_sum ($colors);

        foreach($colors as $k=>$v){
            if($v / $sum > 0.2){
                $background_color[$k] = true;
            } else {
                $background_color[$k] = false;
            }
        }
        */


        foreach ($this->pixels as $x => $row){
            foreach ($row as $y => $pixel){
                //@$xs[$x] += $pixel['a'];
                //@$ys[$y] += $pixel['a'];
                $color = implode(",", $pixel);
                if(isset($background_color[$color])){
                    @$xs[$x] += 0;
                    @$ys[$y] += 0;
                } else {
                    @$xs[$x] += 1;
                    @$ys[$y] += 1;
                }
            }
        }

        while (next($xs)==0 && next($xs)!==false);
        $minX = max(0, (key($xs) - 5));

        while (next($ys)==0  && next($ys)!==false);
        $minY = max(0, (key($ys) - 5));

        end($xs);
        while (prev($xs)==0  && prev($xs)!==false);
        $maxX =  min($this->x , (key($xs) + 5));

        end($ys);
        while (prev($ys)==0  && prev($ys)!==false);
        $maxY =  min($this->y , (key($ys) + 5));

        $return = array('minX' => $minX, 'minY' => $minY, 'maxX' => $maxX, 'maxY' => $maxY);

        #print_r($background_color);
        #print_r($return);
        #die();
        return $return;
    }


    function fromRGB($R, $G, $B){
        $R=dechex($R);
        If (strlen($R)<2)
        $R='0'.$R;
         
        $G=dechex($G);
        If (strlen($G)<2)
        $G='0'.$G;
         
        $B=dechex($B);
        If (strlen($B)<2)
        $B='0'.$B;
     
        return '#' . $R . $G . $B;
    }

    function PixelToImage(){
        $image = new Imagick();

        $image->newImage($this->x, $this->y, new ImagickPixel("#ffffff"));

        $it = $image->getPixelIterator();

        /* Loop trough pixel rows */
        foreach( $it as $y => $pixels )
        {
            foreach ( $pixels as $x => $pixel )
            {
                $colour = $this->fromRGB($this->pixels[$x][$y]['r'], $this->pixels[$x][$y]['g'], $this->pixels[$x][$y]['b']);
                $pixel->setColor($colour);
            }

            $it->syncIterator();
        }
        return $image;
    }

    function setDimension($x, $y){
        $this->x = $x;
        $this->y = $y;
    }

    function getDimension(){
        return array($this->x, $this->y);
    }

    function setPixels($x, $y, $pixels){
        $this->setDimension($x,$y);
        $this->pixels = $pixels;
    }

    function getPixels(){
        return $this->pixels;
    }

    function save($filename){
        $image = imagecreatetruecolor($this->x, $this->y);
        //$whiteBackground = imagecolorallocatealpha($image, 255, 255, 255, 0);
        //$image->setBackgroundColor(new ImagickPixel('transparent'));
        //imagefill($image,0,0, new ImagickPixel('transparent'));
        
        $pixels = $this->pixels;
        foreach ($pixels as $x => $row){
            if($this->x < $x){
                continue;
            }
            foreach ($row as $y => $pixel){
                if($this->y < $y){
                    continue;
                }

                $colour = imagecolorallocatealpha ($image, $pixel['r'], $pixel['g'], $pixel['b'], $pixel['a']); 
                imagesetpixel($image,$x,$y,$colour);
            }
        }

        imagepng($image,$filename);
    }
}

