#include "RosenthalTemperatureParsed.h"
#include "MooseMesh.h"
#include "AuxiliarySystem.h"
#include "libmesh/utility.h"
#include "MathUtils.h"
#include "Function.h"

registerMooseObject("MalamuteApp", RosenthalTemperatureParsed);

InputParameters
RosenthalTemperatureParsed::validParams()
{
    InputParameters params = GeneralUserObject::validParams();
    params.addRequiredParam<Real>("thermal_conductivity", "thermal conductivity of the material");
    params.addRequiredParam<Real>("specific_heat", "specific heat of the material");
    params.addRequiredParam<Real>("density", "density of the material");
    params.addRequiredParam<Real>("power", "applied power as external heat");
    params.addRequiredParam<FunctionName>("velocity_x", "velocity of the moving heat source in x-direction");
    params.addRequiredParam<Real>("melting_temp", "melting temperature of the material");
    params.addRequiredParam<Real>("ambient_temp", "minimum temperature of the surrounding material");
    params.addRequiredParam<FunctionName>("velocity_y", "velocity of the moving heat source in y-direction");
    params.addRequiredParam<FunctionName>("x0", "initial location of the moving source center in x-direction");
    params.addRequiredParam<FunctionName>("y0", "initial location of the moving source center in y-direction");
    params.addParam<Real>("maximum_temp", -273, "maximum allowable temperature in the field. Default is melting temperature + 10");

    return params;
}

RosenthalTemperatureParsed::RosenthalTemperatureParsed(const InputParameters & parameters)
 : GeneralUserObject(parameters),
    _kappa(parameters.get<Real>("thermal_conductivity")),
    _rho(parameters.get<Real>("density")),
    _cp(parameters.get<Real>("specific_heat")),
    _Q(parameters.get<Real>("power")),
    _Vx(getFunction("velocity_x")),
    _Vy(getFunction("velocity_y")),
    _x0(getFunction("x0")),
    _y0(getFunction("y0")),
    _Tm(parameters.get<Real>("melting_temp")),
    _To(parameters.get<Real>("ambient_temp")),
    _Tmax(parameters.get<Real>("maximum_temp"))
 {
    if (_Tmax == -273)
    {
        _Tmax = _Tm + 10;
    }
 }

Real
RosenthalTemperatureParsed::thermal_conductivity() const
{
    return _kappa;
}

Real
RosenthalTemperatureParsed::density() const
{
    return _rho;
}

Real
RosenthalTemperatureParsed::specific_heat() const
{
    return _cp;
}

Real
RosenthalTemperatureParsed::power() const
{
    return _Q;
}

Real
RosenthalTemperatureParsed::melting_temp() const
{
    return _Tm;
}

Real
RosenthalTemperatureParsed::ambient_temp() const
{
    return _To;
}

Real
RosenthalTemperatureParsed::maximum_temp() const
{
    return _Tmax;
}

Real
RosenthalTemperatureParsed::value(const Point & p) const
{
    Real vx = _Vx.value(_t, p);
    Real vy = _Vy.value(_t, p);
    Real xt = p(0) - _x0.value(_t, p) - vx * _t;
    Real yt = p(1) - _y0.value(_t, p) - vy * _t;
    Real R = std::sqrt((xt*xt)+(yt*yt)+(p(2)*p(2)));
    Real expo = -1*(std::abs(vx)*(R + xt * MathUtils::sign(vx)) + std::abs(vy)*(R + yt * MathUtils::sign(vy)));
    Real temperature = _To + (_Q/(2*libMesh::pi*_kappa*R))*std::exp(expo/(2*_kappa/(_rho*_cp)));

    if (temperature >= _Tmax)
    {
        temperature = _Tmax;
    }
    return temperature;
}

Real
RosenthalTemperatureParsed::spatialValue(const Point & p) const
{
    Real vx = _Vx.value(_t, p);
    Real vy = _Vy.value(_t, p);
    Real xt = p(0) - _x0.value(_t, p) - vx * _t;
    Real yt = p(1) - _y0.value(_t, p) - vy * _t;
    Real R = std::sqrt((xt*xt)+(yt*yt)+(p(2)*p(2)));
    Real expo = -1*(std::abs(vx)*(R + xt * MathUtils::sign(vx)) + std::abs(vy)*(R + yt * MathUtils::sign(vy)));
    Real temperature = _To + (_Q/(2*libMesh::pi*_kappa*R))*std::exp(expo/(2*_kappa/(_rho*_cp)));

    if (temperature >= _Tmax)
    {
        temperature = _Tmax;
    }

    return temperature;
}