function start = drawJustifiedText(window, string, alignment, size, style, line_height, text_block_width, font_ratio, font_family, color, flip)

if nargin < 11
    flip = 1;
end

gray                                = [103, 103, 103];
screenWidth                         = 1920;
screenHeight                        = 1080;
resolution                          = [screenWidth, screenHeight];
textOffset                          = 0.05;
textLeftOffset                      = 2*textOffset*screenWidth; % in pixels
DrawFormattedText(window, string, 'justifytomax', textLeftOffset + line_height*size/2, gray, 99, 0, 0, line_height, 0, [textLeftOffset textLeftOffset (resolution - textLeftOffset)]);

if flip
    start = Screen(window, 'Flip');
end


