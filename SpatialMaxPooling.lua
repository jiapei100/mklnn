local SpatialMaxPooling, parent = torch.class('mklnn.SpatialMaxPooling', 'nn.Module')

local wrapper = mklnn.wrapper
local getType = mklnn.getType

function SpatialMaxPooling:__init(kW, kH, dW, dH, padW, padH)
   parent.__init(self)

   dW = dW or kW
   dH = dH or kH
   self.kW = kW
   self.kH = kH
   self.dW = dW
   self.dH = dH
   self.padW = padW or 0
   self.padH = padH or 0
   self.ceil_mode = false
end

function SpatialMaxPooling:ceil()
   self.ceil_mode = true
   return self
end

function SpatialMaxPooling:floor()
   self.ceil_mode = false
   return self
end

function SpatialMaxPooling:updateOutput(input)

   if self.dnnPrimitives then
      self.mkldnnInitOk = 1
   else
      self.mkldnnInitOk = 0
   end
   self.dnnPrimitives = self.dnnPrimitives or torch.LongTensor(16)

   self.output = self.output:mkl() --add
   self.gradInput = self.gradInput:mkl()

   -- backward compatibility
   self.ceil_mode = self.ceil_mode or false
   self.padW = self.padW or 0
   self.padH = self.padH or 0

   --print("SpatialMaxPooling output nElement = ",self.output:nElement())
    wrapper(getType(input),'SpatialMaxPooling_updateOutput',
       input:cdata(),
       self.output:cdata(),
       self.kW, self.kH,
       self.dW, self.dH,
       self.padW, self.padH,
       self.ceil_mode,
       self.dnnPrimitives:cdata(),
       self.mkldnnInitOk)
   return self.output
end

function SpatialMaxPooling:updateGradInput(input, gradOutput)

   wrapper(getType(input),'SpatialMaxPooling_updateGradInput',
      input:cdata(),
      gradOutput:cdata(),
      self.gradInput:cdata(),
      self.kW, self.kH,
      self.dW, self.dH,
      self.padW, self.padH,
      self.ceil_mode,
      self.dnnPrimitives:cdata(),self.mkldnnInitOk)
   return self.gradInput
end

-- for backward compat
function SpatialMaxPooling:empty()
   --self:clearState()
end

function SpatialMaxPooling:__tostring__()
   local s =  string.format('%s(%d,%d,%d,%d', torch.type(self),
                            self.kW, self.kH, self.dW, self.dH)
   if (self.padW or self.padH) and (self.padW ~= 0 or self.padH ~= 0) then
      s = s .. ',' .. self.padW .. ','.. self.padH
   end
   s = s .. ')'

   return s
end

function SpatialMaxPooling:clearState()
   return parent.clearState(self)
end
