package morn.core.components;

import morn.core.utils.BitmapUtils;
import morn.core.handlers.Handler;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
class AutoBitmap extends Bitmap {
    private var _width:Float = Math.NaN;
    private var _height:Float = Math.NaN;
    private var _sizeGrid:Array<Int> = null;
    private var _source:Array<BitmapData>;
    private var _clips:Array<BitmapData>;
    private var _index:Int = 0;
    private var _anchorX:Float = Math.NaN;
    private var _anchorY:Float = Math.NaN;
    private var _changeSize:Handler = null;
    public function new() {
        super();
        _changeSize=new Handler(changeSize.bind());
    }
    #if flash
    /**宽度(显示时四舍五入)*/
    @:getter(width)
    private function get_width():Float {
        return Math.isNaN(_width) ? (this.bitmapData!=null ? this.bitmapData.width : super.width) : _width;
    }
    @:setter(width)
    private function set_width(value:Float):Void {
        if (_width != value) {
            _width = value;
            App.render.callLater(_changeSize);
        }
    }
    /**高度(显示时四舍五入)*/
    @:getter(height)
    private function get_height():Float {
        return Math.isNaN(_height) ? (this.bitmapData!=null ? this.bitmapData.height : super.height) : _height;
    }
    @:setter(height)
    private function set_height(value:Float):Void {
        if (_height != value) {
            _height = value;
            App.render.callLater(_changeSize);
        }
    }
    @:setter(bitmapData)
    private function set_bitmapData(value:BitmapData):Void {
        if (value!=null) {
            clips = [value];
        } else {
            disposeTempBitmapdata();
            _source = null;
            _clips = null;
            super.bitmapData = null;
        }
    }
    #else
    /**宽度(显示时四舍五入)*/
    private override function get_width():Float {
        return Math.isNaN(_width) ? (this.bitmapData!=null ? this.bitmapData.width : super.width) : _width;
    }
    private override function set_width(value:Float):Float {
        if (_width != value) {
            _width = value;
            App.render.callLater(_changeSize);
        }
        return value;
    }
    /**高度(显示时四舍五入)*/
    private override function get_height():Float {
        return Math.isNaN(_height) ? (this.bitmapData!=null ? this.bitmapData.height : super.height) : _height;
    }
    private override function set_height(value:Float):Float {
        if (_height != value) {
            _height = value;
            App.render.callLater(_changeSize);
        }
        return value;
    }
    private override function set_bitmapData(value:BitmapData):BitmapData {
        if (value!=null) {
            clips = [value];
        } else {
            disposeTempBitmapdata();
            _source = null;
            _clips = null;
            super.bitmapData = null;
        }
        return value;
    }
    #end

    public var sizeGrid(get,set):Array<Int>;
    private function get_sizeGrid():Array<Int> {
        return _sizeGrid;
    }
    private function set_sizeGrid(value:Array<Int>):Array<Int> {
        _sizeGrid = value;
        App.render.callLater(_changeSize);
        return value;
    }

    /**位图切片集合*/
    public var clips(get,set):Array<BitmapData>;
    private function get_clips():Array<BitmapData> {
        return _source;
    }
    private function set_clips(value:Array<BitmapData>):Array<BitmapData> {
        disposeTempBitmapdata();
        _source = value;
        if (value!=null && value.length > 0) {
            super.bitmapData = value[0];
            App.render.callLater(_changeSize);
        }
        return value;
    }
    /**当前切片索引*/
    public var index(get,set):Int;
    private function get_index():Int {
        return _index;
    }
    private function set_index(value:Int):Int {
        value = Std.int(value);
        _index = value;
        if (_clips!=null && _clips.length > 0) {
            _index = (_index < _clips.length && _index > -1) ? _index : 0;
            super.bitmapData = _clips[_index];
        }
        return _index;
    }
    private function changeSize():Void {
        if (_source!=null && _source.length > 0) {
            var w:Int = Math.round(width);
            var h:Int = Math.round(height);
            //清理临时位图数据
            disposeTempBitmapdata();
            //重新生成新位图
            var temp:Array<BitmapData> = [];
            for (i in 0..._source.length) {
                if (_sizeGrid!=null) {
                    temp.push(BitmapUtils.scale9Bmd(_source[i], _sizeGrid, w, h));
                } else {
                    temp.push(_source[i]);
                }
            }
            _clips = temp;
            index = _index;
            super.width = w;
            super.height = h;
        }
        if (!Math.isNaN(_anchorX)) {
            super.x = -Math.round(_anchorX * width);
        }
        if (!Math.isNaN(_anchorY)) {
            super.y = -Math.round(_anchorY * height);
        }
    }
    /**销毁临时位图*/
    private function disposeTempBitmapdata():Void {
        if (_clips!=null) {
            var i:Int=_clips.length - 1;
            while(i>0) {
                if (_clips[i] != _source[i]) {
                    _clips[i].dispose();
                }
                i--;
            }
            _clips=[];
        }
    }

    /**销毁*/
    public function dispose():Void {
        if (_clips!=null) {
            var i:Int=_clips.length - 1;
            while(i>0) {
                _clips[i].dispose();
                i--;
            }
            _clips=[];
        }
        _sizeGrid = null;
        _source = null;
        _clips = null;
        bitmapData = null;
    }
    /**X锚点，值为0-1*/
    public var anchorX(get,set):Float;
    private function get_anchorX():Float {
        return _anchorX;
    }
    private function set_anchorX(value:Float):Float {
        value = Std.parseFloat(Std.string(value));
        _anchorX = value;
        return value;
    }

    /**Y锚点，值为0-1*/
    public var anchorY(get,set):Float;
    private function get_anchorY():Float {
        return _anchorY;
    }
    private function set_anchorY(value:Float):Float {
        value = Std.parseFloat(Std.string(value));
        _anchorY = value;
        return value;
    }
}
